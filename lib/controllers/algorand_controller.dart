import 'package:get/get.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/sevices/algorand.dart';
import 'package:login_signup_screen/widgets/loading.dart';

class AlgorandController extends GetxController {
  static AlgorandController instance = Get.find();
  RxString publicAddress = ''.obs;
  RxList privateKey = [].obs;
  RxString publicKey = ''.obs;
  RxList words = [].obs;
  Account account;
  Account restoredAccount;
  final _storage = GetStorage();

  Future<Account> createAlgorandWallet() async {
    showLoading();
    account = await algorand.createAccount();

    //With the given account, you can easily extract the public Algorand address, signing keys and seedphrase/mnemonic.

    publicAddress.value = account.publicAddress;
    print(
        "==========public address=========== ${publicAddress.value} ====================");

    privateKey.value = await account.keyPair.extractPrivateKeyBytes();
    print("==========private key=========== $privateKey ====================");

    //==================================================

    /*Get the 25-word seed phrase/mnemonic.
    This converts the private 32-byte key into a 25 word mnemonic. 
    The generated mnemonic includes a checksum. 
    Each word in the mnemonic represents 11 bits of data, and the last 11 bits are reserved for the checksum.*/

    words.value = await account.seedPhrase; // returns a list of strings
    print("==========seed Phrase=========== $words ====================");
    //==================================================
    //storing values in the local database
    final key = privateKey;
    _storage.write("publicAddress", publicAddress.value);
    _storage.write("privateKey", key);
    _storage.write("words", words);
    Map<String, dynamic> data = {
      "public_address": publicAddress.value,
      "private_key": key,
      "seed_phrase": words,
    };
    userController.updateUserData(data);
    dismissLoading();
    return account;
  }

  loadAccount() async {
    // account = await algorand.loadAccountFromSeed(seed);
  }
  Future<String> createPayment(address) async {
    showLoading();
    final newAccount = await algorand.loadAccountFromSeed(address);
    var transactionID = await algorand.sendPayment(
      account: account,
      recipient: newAccount.address,
      amount: Algo.toMicroAlgos(5),
      note: 'Hi from Flutter!',
      waitForConfirmation: true,
      timeout: 3,
    );
    dismissLoading();
    return transactionID;
  }

  Future<Account> restoreAccount(List<String> words) async {
    try {
      showLoading();
      //Recovering an account from your 25-word mnemonic/seedphrase can be done by passing an array or space delimited string

      restoredAccount = await algorand.restoreAccount(words);
      privateKey.value = await restoredAccount.keyPair.extractPrivateKeyBytes();
      print(
          "==========private key=========== $privateKey ====================");
      publicAddress.value = account.publicAddress;
      print(
          "==========public address=========== ${publicAddress.value} ====================");
      //==================================================

      /*Get the 25-word seed phrase/mnemonic.
    This converts the private 32-byte key into a 25 word mnemonic. 
    The generated mnemonic includes a checksum. 
    Each word in the mnemonic represents 11 bits of data, and the last 11 bits are reserved for the checksum.*/

      //==================================================
      //storing values in the local database
      final key = privateKey;
      _storage.write("publicAddress", publicAddress.value);
      _storage.write("privateKey", key);
      if(restoredAccount != null){
         Map data = {
        "public_address": publicAddress.value,
        "private_key": key,
        "seed_phrase": words,
      };
      userController.updateUserData(data);
      }
      Map data = {
        "public_address": publicAddress.value,
        "private_key": key,
        "seed_phrase": words,
      };
      userController.updateUserData(data);
      dismissLoading();
      return restoredAccount;
    } catch (e) {
      return null;
    }
  }
}
