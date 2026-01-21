import 'package:events_emitter/listener.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/app_text_field.dart';
import 'package:fintracker/widgets/app/section_header.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:fintracker/widgets/currency.dart';
import 'package:fintracker/widgets/dialog/account_form.dialog.dart';
import 'package:fintracker/widgets/dialog/category_form.dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

typedef OnCloseCallback = Function(Payment payment);
final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

class PaymentForm extends StatefulWidget {
  final PaymentType type;
  final Payment? payment;
  final OnCloseCallback? onClose;

  const PaymentForm({super.key, required this.type, this.payment, this.onClose});

  @override
  State<PaymentForm> createState() => _PaymentForm();
}

class _PaymentForm extends State<PaymentForm> {
  bool _initialised = false;
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  final CategoryDao _categoryDao = CategoryDao();

  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  int? _id;
  String _title = '';
  String _description = '';
  Account? _account;
  Category? _category;
  double _amount = 0;
  PaymentType _type = PaymentType.credit;
  DateTime _datetime = DateTime.now();

  loadAccounts() {
    _accountDao.find().then((value) {
      setState(() {
        _accounts = value;
      });
    });
  }

  loadCategories() {
    _categoryDao.find().then((value) {
      setState(() {
        _categories = value;
      });
    });
  }

  void populateState() async {
    await loadAccounts();
    await loadCategories();
    if (widget.payment != null) {
      setState(() {
        _id = widget.payment!.id;
        _title = widget.payment!.title;
        _description = widget.payment!.description;
        _account = widget.payment!.account;
        _category = widget.payment!.category;
        _amount = widget.payment!.amount;
        _type = widget.payment!.type;
        _datetime = widget.payment!.datetime;
        _initialised = true;
      });
    } else {
      setState(() {
        _type = widget.type;
        _initialised = true;
      });
    }
  }

  Future<void> chooseDate(BuildContext context) async {
    DateTime initialDate = _datetime;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && initialDate != picked) {
      setState(() {
        _datetime = DateTime(picked.year, picked.month, picked.day, initialDate.hour, initialDate.minute);
      });
    }
  }

  Future<void> chooseTime(BuildContext context) async {
    DateTime initialDate = _datetime;
    TimeOfDay initialTime = TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time != null && initialTime != time) {
      setState(() {
        _datetime = DateTime(initialDate.year, initialDate.month, initialDate.day, time.hour, time.minute);
      });
    }
  }

  void handleSaveTransaction(context) async {
    Payment payment = Payment(
      id: _id,
      account: _account!,
      category: _category!,
      amount: _amount,
      type: _type,
      datetime: _datetime,
      title: _title,
      description: _description,
    );
    await _paymentDao.upsert(payment);
    if (widget.onClose != null) {
      widget.onClose!(payment);
    }
    Navigator.of(context).pop();
    globalEvent.emit('payment_update');
  }

  @override
  void initState() {
    super.initState();
    populateState();
    _accountEventListener = globalEvent.on('account_update', (data) {
      debugPrint('accounts are changed');
      loadAccounts();
    });

    _categoryEventListener = globalEvent.on('category_update', (data) {
      debugPrint('categories are changed');
      loadCategories();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialised) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.payment == null ? 'Giao dịch mới' : 'Chỉnh sửa giao dịch',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Loại giao dịch',
                    subtitle: 'Chọn loại để phân loại thu nhập hoặc chi phí.',
                  ),
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        ChoiceChip(
                          label: const Text('Thu nhập'),
                          selected: _type == PaymentType.credit,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _type = PaymentType.credit;
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Chi phí'),
                          selected: _type == PaymentType.debit,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _type = PaymentType.debit;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Thông tin giao dịch',
                    subtitle: 'Nhập tiêu đề, ghi chú và số tiền.',
                  ),
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Tiêu đề',
                          hintText: 'Nhập tiêu đề',
                          initialValue: _title,
                          onChanged: (text) => setState(() => _title = text),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Mô tả',
                          hintText: 'Ghi chú thêm',
                          initialValue: _description,
                          maxLines: 3,
                          onChanged: (text) => setState(() => _description = text),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Số tiền',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                          ],
                          prefix: CurrencyText(null),
                          initialValue: _amount == 0 ? '' : _amount.toString(),
                          onChanged: (String text) {
                            setState(() {
                              _amount = double.parse(text == '' ? '0' : text);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Ngày và giờ',
                    subtitle: 'Thiết lập thời điểm diễn ra giao dịch.',
                  ),
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Ngày',
                            readOnly: true,
                            onTap: () => chooseDate(context),
                            initialValue: DateFormat('dd/MM/yyyy').format(_datetime),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: 'Giờ',
                            readOnly: true,
                            onTap: () => chooseTime(context),
                            initialValue: DateFormat('HH:mm').format(_datetime),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Chọn tài khoản',
                    subtitle: 'Chọn ví để ghi nhận giao dịch.',
                  ),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: SizedBox(
                      height: 92,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(_accounts.length + 1, (index) {
                          if (index == 0) {
                            return SizedBox(
                              width: 140,
                              child: AppCard(
                                onTap: () {
                                  showDialog(context: context, builder: (builder) => const AccountForm());
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: theme.colorScheme.primary),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text('Tạo mới', style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            );
                          }
                          Account account = _accounts[index - 1];
                          final isSelected = _account?.id == account.id;
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            child: AppCard(
                              onTap: () {
                                setState(() {
                                  _account = account;
                                });
                              },
                              color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(account.icon, color: account.color, size: 20),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    account.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Chọn danh mục',
                    subtitle: 'Gắn giao dịch vào danh mục phù hợp.',
                  ),
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: List.generate(_categories.length + 1, (index) {
                        if (_categories.length == index) {
                          return AppButton(
                            label: 'Tạo mới',
                            icon: Icons.add,
                            variant: AppButtonVariant.secondary,
                            onPressed: () {
                              showDialog(context: context, builder: (builder) => const CategoryForm());
                            },
                          );
                        }
                        Category category = _categories[index];
                        final isSelected = _category?.id == category.id;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.icon, color: category.color, size: 18),
                              const SizedBox(width: AppSpacing.xs),
                              Text(category.name),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _category = category;
                            });
                          },
                          selectedColor: theme.colorScheme.primaryContainer,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Lưu giao dịch',
            onPressed: _amount > 0 && _account != null && _category != null
                ? () => handleSaveTransaction(context)
                : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            size: AppButtonSize.large,
          ),
        ],
      ),
    );
  }
}
