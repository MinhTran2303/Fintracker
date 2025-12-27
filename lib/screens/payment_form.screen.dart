import 'package:events_emitter/listener.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/theme/colors.dart';
import 'package:fintracker/widgets/currency.dart';
import 'package:fintracker/widgets/dialog/account_form.dialog.dart';
import 'package:fintracker/widgets/dialog/category_form.dialog.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fintracker/theme/background.dart';

typedef OnCloseCallback = Function(Payment payment);
final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
class PaymentForm extends StatefulWidget{
  final PaymentType  type;
  final Payment?  payment;
  final OnCloseCallback? onClose;

  const PaymentForm({super.key, required this.type, this.payment, this.onClose});

  @override
  State<PaymentForm> createState() => _PaymentForm();
}

class _PaymentForm extends State<PaymentForm>{
  bool _initialised = false;
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  final CategoryDao _categoryDao = CategoryDao();

  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  //values
  int? _id;
  String _title = "";
  String _description="";
  Account? _account;
  Category? _category;
  double _amount=0;
  PaymentType _type= PaymentType.credit;
  DateTime _datetime = DateTime.now();

  loadAccounts(){
    _accountDao.find().then((value){
      setState(() {
        _accounts = value;
      });
    });
  }

  loadCategories(){
    _categoryDao.find().then((value){
      setState(() {
        _categories = value;
      });
    });
  }

  void populateState() async{
    await loadAccounts();
    await loadCategories();
    if(widget.payment != null) {
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
    }
    else
    {
      setState(() {
        _type =  widget.type;
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
        lastDate: DateTime.now()
    );
    if(picked!=null  && initialDate != picked) {
      setState(() {
        _datetime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            initialDate.hour,
            initialDate.minute
        );
      });
    }
  }

  Future<void> chooseTime(BuildContext context) async {
    DateTime initialDate = _datetime;
    TimeOfDay initialTime = TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
    final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.input
    );
    if (time != null && initialTime !=time) {
      setState(() {
        _datetime = DateTime(
            initialDate.year,
            initialDate.month,
            initialDate.day,
            time.hour,
            time.minute
        );
      });
    }
  }

  void handleSaveTransaction(context) async{
    Payment payment = Payment(id: _id,
        account: _account!,
        category: _category!,
        amount: _amount,
        type: _type,
        datetime: _datetime,
        title: _title,
        description: _description
    );
    await _paymentDao.upsert(payment);
    if (widget.onClose != null) {
      widget.onClose!(payment);
    }
    Navigator.of(context).pop();
    globalEvent.emit("payment_update");
  }


  @override
  void initState()  {
    super.initState();
    populateState();
    _accountEventListener = globalEvent.on("account_update", (data){
      debugPrint("accounts are changed");
      loadAccounts();
    });

    _categoryEventListener = globalEvent.on("category_update", (data){
      debugPrint("categories are changed");
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
    if(!_initialised) return const CircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.payment ==null? "Giao dịch mới": "Chỉnh sửa giao dịch"}", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: pageBackgroundDecoration(context),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Type
                    Text(
                      "Loại giao dịch",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text("Thu nhập"),
                          selected: _type == PaymentType.credit,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _type = PaymentType.credit;
                            });
                            }
                          },
                        ),
                        FilterChip(
                          label: const Text("Chi phí"),
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
                    const SizedBox(height: 24),

                    // Title
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Tiêu đề",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      initialValue: _title,
                      onChanged: (text) {
                        setState(() {
                          _title = text;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Mô tả",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      initialValue: _description,
                      onChanged: (text) {
                        setState(() {
                          _description = text;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                      ],
                      decoration: InputDecoration(
                        labelText: "Số tiền",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: CurrencyText(null),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      initialValue: _amount == 0 ? "" : _amount.toString(),
                      onChanged: (String text) {
                        setState(() {
                          _amount = double.parse(text == "" ? "0" : text);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Date and Time
                    Text(
                      "Ngày và giờ",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => chooseDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Ngày",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(DateFormat("dd/MM/yyyy").format(_datetime)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => chooseTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Giờ",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(DateFormat("HH:mm").format(_datetime)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Account Selection
                    Text(
                      "Chọn tài khoản",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(_accounts.length + 1, (index) {
                          if (index == 0) {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 8),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(context: context, builder: (builder) => const AccountForm());
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Tạo mới"),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          }
                          Account account = _accounts[index - 1];
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _account = account;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _account?.id == account.id ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                                  width: _account?.id == account.id ? 2 : 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(account.icon, color: account.color, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    account.name,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Selection
                    Text(
                      "Chọn danh mục",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_categories.length + 1, (index) {
                        if (_categories.length == index) {
                          return OutlinedButton.icon(
                            onPressed: () {
                              showDialog(context: context, builder: (builder) => const CategoryForm());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Tạo mới"),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                        Category category = _categories[index];
                        return OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _category = category;
                            });
                          },
                          onLongPress: () {
                            showDialog(context: context, builder: (builder) => CategoryForm(category: category));
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _category?.id == category.id ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                              width: _category?.id == category.id ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.icon, color: category.color, size: 18),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _amount > 0 && _account != null && _category != null ? () => handleSaveTransaction(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Lưu giao dịch"),
          ),
        ),
      ),
    );
  }
}
