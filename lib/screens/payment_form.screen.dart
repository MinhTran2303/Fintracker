import 'package:events_emitter/listener.dart';
import 'package:SpendingMonitor/dao/account_dao.dart';
import 'package:SpendingMonitor/dao/category_dao.dart';
import 'package:SpendingMonitor/dao/payment_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/model/account.model.dart';
import 'package:SpendingMonitor/model/category.model.dart';
import 'package:SpendingMonitor/model/payment.model.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_card.dart';
import 'package:SpendingMonitor/widgets/app/app_scaffold.dart';
import 'package:SpendingMonitor/widgets/app/app_text_field.dart';
import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:SpendingMonitor/widgets/currency.dart';
import 'package:SpendingMonitor/widgets/dialog/account_form.dialog.dart';
import 'package:SpendingMonitor/widgets/dialog/category_form.dialog.dart';
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
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                          ),
                          child: Icon(
                            widget.payment == null ? Icons.add_circle_outline : Icons.edit,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.payment == null ? 'Tạo giao dịch' : 'Cập nhật giao dịch',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Ghi lại thu chi để theo dõi dòng tiền.',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Loại giao dịch', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
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
                              selectedColor: theme.colorScheme.primaryContainer,
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
                              selectedColor: theme.colorScheme.primaryContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ngày và giờ', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chọn tài khoản', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 96,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chọn danh mục', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.sm),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final itemWidth = (availableWidth - AppSpacing.sm) / 2;
                            return Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: List.generate(_categories.length + 1, (index) {
                                if (_categories.length == index) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: AppCard(
                                      onTap: () {
                                        showDialog(context: context, builder: (builder) => const CategoryForm());
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceVariant,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                                            ),
                                            child: Icon(Icons.library_add, color: theme.colorScheme.primary, size: 18),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              'Tạo mới',
                                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                Category category = _categories[index];
                                final isSelected = _category?.id == category.id;
                                return SizedBox(
                                  width: itemWidth,
                                  child: AppCard(
                                    onTap: () {
                                      setState(() {
                                        _category = category;
                                      });
                                    },
                                    color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                                          ),
                                          child: Icon(
                                            isSelected ? Icons.check_circle : Icons.layers,
                                            color: isSelected ? theme.colorScheme.primary : category.color,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                category.name,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? theme.colorScheme.onPrimaryContainer
                                                      : theme.colorScheme.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: AppSpacing.xs),
                                              Text(
                                                'Chọn',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: isSelected
                                                      ? theme.colorScheme.onPrimaryContainer
                                                      : theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
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
