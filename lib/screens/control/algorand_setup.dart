import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_signup_screen/controllers/algorand_controller.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/home_screen.dart';
import 'package:login_signup_screen/widgets/wallet_card.dart';

class AlgorandSetup extends StatelessWidget {
  final box = GetStorage();
  final AlgorandController _algorandController = Get.find();
  createWallet() async {
    var account = await _algorandController.createAlgorandWallet();
    if (account != null) {
      box.write("walletCreated", true);
      Get.offAll(HomeScreen(index: 3));
    }
  }

  importWallet(input) async {
    var account = await _algorandController.restoreAccount(input);
    if (account != null) {
      box.write("walletCreated", true);
      Get.offAll(HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
          scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Setup Wallet',
            style: Theme.of(context).textTheme.headline5?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallets',
                style: Theme.of(context).textTheme.headline5?.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      //color: Colors.deepPurple,
                    ),
              ),
              SizedBox(height: 40),
              Text(
                'Create or import a wallet to start sending and receiving digital currency',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    //color: Colors.deepPurple,
                    ),
              ),
              Spacer(),
              WalletCard(
                title: 'Create',
                subtitle: 'a new wallet',
                backgroundColor: Colors.blue[800],
                onTapped: () async {
                  final result = await showOkCancelAlertDialog(
                    context: context,
                    title: 'Create new account',
                    message:
                        'This will remove your existing account. Make sure you backed up the passphrase before continuing or you will lose your account.',
                  );

                  if (result == OkCancelResult.ok) {
                    createWallet();
                  }
                },
              ),
              SizedBox(height: 40),
              WalletCard(
                title: 'Import',
                subtitle: 'an existing wallet',
                textColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                onTapped: () async {
                  final result = await showOkCancelAlertDialog(
                    context: context,
                    title: 'Recover from Passphrase',
                    message:
                        'This will remove your existing account. Make sure you backed up the passphrase before continuing or you will lose your account.',
                  );

                  if (result == OkCancelResult.ok) {
                    final input = await showTextInputDialog(
                      textFields: [DialogTextField()],
                      context: context,
                      title: 'Recover from Passphrase',
                      message: 'Recover an account with a 25-word passphrase.',
                    );

                    if (input != null && input.length > 0) {
                      importWallet(input);
                    }
                  }
                },
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
