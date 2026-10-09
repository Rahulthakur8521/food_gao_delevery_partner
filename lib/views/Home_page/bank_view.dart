import 'package:flutter/material.dart';

class BankView extends StatelessWidget {
  final String bankName;
  final String accountHolderName;
  final String ifscCode;
  final String accountNumber;

  BankView({
    required this.bankName,
    required this.accountHolderName,
    required this.ifscCode,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Name: $bankName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Account Holder\'s Name: $accountHolderName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'IFSC Code: $ifscCode',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Account Number: $accountNumber',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
