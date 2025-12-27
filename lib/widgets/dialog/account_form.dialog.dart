import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:fintracker/data/icons.dart';
typedef Callback = void Function();

class AccountForm extends StatefulWidget {
  final Account? account;
  final Callback? onSave;

  const AccountForm({super.key, this.account, this.onSave});

  @override
  State<StatefulWidget> createState() => _AccountForm();
}
class _AccountForm extends State<AccountForm>{
  final AccountDao _accountDao = AccountDao();
  Account? _account;
  @override
  void initState() {
    super.initState();
    if(widget.account != null){
      _account = Account(
          id: widget.account!.id,
          name: widget.account!.name,
          holderName: widget.account!.holderName,
          accountNumber: widget.account!.accountNumber,
          icon: widget.account!.icon,
          color: widget.account!.color
      );
    } else {
      _account = Account(
          name: "",
          holderName: "",
          accountNumber: "",
          icon: Icons.account_circle,
          color: Colors.grey
      );
    }
  }

  void onSave (context) async{
    await _accountDao.upsert(_account!);
    if(widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    globalEvent.emit("account_update");
  }

  void pickIcon(context)async {

  }
  @override
  Widget build(BuildContext context) {
    if(_account == null ){
      return const CircularProgressIndicator();
    }
    final theme = Theme.of(context);

    // Card/dialog surface should be light to contrast with page background
    final dialogSurface = theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    // Build pickers as explicit widget lists to avoid builder signature issues
    final List<Widget> colorWidgets = [];
    for (final color in Colors.primaries) {
      colorWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _account!.color = color;
            });
          },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                width: 2,
                color: _account!.color.value == color.value ? Colors.white : Colors.transparent,
              ),
            ),
          ),
        ),
      ));
    }

    final List<Widget> iconWidgets = [];
    for (final iconData in AppIcons.icons) {
      iconWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _account!.icon = iconData;
            });
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: _account!.icon == iconData ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(iconData, color: Theme.of(context).colorScheme.primary, size: 18),
          ),
        ),
      ));
    }

    final List<Widget> dialogChildren = [
      const SizedBox(height: 15),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(color: _account!.color, borderRadius: BorderRadius.circular(40)),
            alignment: Alignment.center,
            child: Icon(_account!.icon, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: TextFormField(
              initialValue: _account!.name,
              decoration: InputDecoration(
                labelText: 'Tên ví',
                hintText: 'Tên tài khoản',
                filled: true,
                fillColor: dialogSurface,
                labelStyle: TextStyle(color: secondaryTextColor),
                hintStyle: TextStyle(color: secondaryTextColor.withAlpha(180)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: theme.colorScheme.outline)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              ),
              onChanged: (String text) => setState(() => _account!.name = text),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: _account!.holderName,
        decoration: InputDecoration(
          labelText: 'Tên chủ',
          hintText: 'Nhập tên chủ tài khoản',
          filled: true,
          fillColor: dialogSurface,
          labelStyle: TextStyle(color: secondaryTextColor),
          hintStyle: TextStyle(color: secondaryTextColor.withAlpha(180)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: theme.colorScheme.outline)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        ),
        onChanged: (text) => setState(() => _account!.holderName = text),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: _account!.accountNumber,
        decoration: InputDecoration(
          labelText: 'Số tài khoản',
          hintText: 'Nhập số tài khoản',
          filled: true,
          fillColor: dialogSurface,
          labelStyle: TextStyle(color: secondaryTextColor),
          hintStyle: TextStyle(color: secondaryTextColor.withAlpha(180)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: theme.colorScheme.outline)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        ),
        onChanged: (text) => setState(() => _account!.accountNumber = text),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 45,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: colorWidgets),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 45,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: iconWidgets),
        ),
      ),
    ];

    return AlertDialog(
      backgroundColor: dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.account != null ? "Chỉnh sửa ví" : "Ví mới", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: primaryTextColor)),
      insetPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: dialogChildren),
      ),
      actions: [
        AppButton(
          height: 45,
          isFullWidth: true,
          onPressed: () {
            onSave(context);
          },
          color: Theme.of(context).colorScheme.primary,
          label: "Lưu",
        )
      ],
    );
  }

}