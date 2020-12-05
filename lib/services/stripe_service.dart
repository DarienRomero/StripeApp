import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:stripe_payment/stripe_payment.dart';
import 'package:stripe_app/models/payment_intent_response.dart';
import 'package:stripe_app/models/stripe_custom_response.dart';

class StripeService{
    StripeService._privateConstructor();
    static final StripeService _instance = StripeService._privateConstructor();
    factory StripeService() =>_instance;

    String _paymentApiUrl = "https://api.stripe.com/v1/payment_intents";
    static String _secretKey = "sk_test_51HuiX5Hzr4HkjUcHRMveT3wrKcruThrEczxx5gYBVL7aHxsW0BNXwc1faxmpYQgAyrZXknQyMPbI127pDfsCZLFv00UQ1Bgriv";
    String _apiKey = "pk_test_51HuiX5Hzr4HkjUcHqYpS7jXVKuwKJ9GjBYzU3Q574PraxzvLaGC4AEgAizPK6CDC40ResNmWR6JFp1vRFlDzI5FS002avlvr2H";

    final headerOptions = Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        'Authorization': 'Bearer ${StripeService._secretKey}',
      }
    );
    void init(){
      StripePayment.setOptions(
        StripeOptions(
          publishableKey: this._apiKey,
          androidPayMode: 'test',
          merchantId: 'test'
        )
      );
    }
    Future<StripeCustomResponse> pagarConTarjetaExistente({
      @required String amount,
      @required String currency,
      @required CreditCard card,
    }) async {
      
    }
    Future pagarConNuevaTarjeta({
      @required String amount,
      @required String currency,
    }) async {
      try {
        final paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest()
        );
        final resp = await this._realizarPago(
          amount: amount,
          currency: currency,
          paymentMethod: paymentMethod
        );
        return resp;
      } catch (e) {
        return StripeCustomResponse(
          ok: false,
          msg: e.toString()
        );
      }
    }
    Future pagarConGooglePayApplePay({
      @required String amount,
      @required String currency,
    }) async {

    }
    Future<PaymentIntentResponse> _crearPaymentIntent({
      @required String amount,
      @required String currency,
    }) async {
      try {
        final dio = new Dio();
        final data = {
          'amount': amount,
          'currency': currency,
        };
        final respuesta = await dio.post(
          _paymentApiUrl,
          data: data,
          options: headerOptions
        );

        return PaymentIntentResponse.fromJson(respuesta.data);  
      } catch (e) {
        print("Error en intento: " + e.toString());
        return PaymentIntentResponse(
          status: '480'
        );
      }
    }
    Future<StripeCustomResponse> _realizarPago({
      @required String amount,
      @required String currency,
      @required PaymentMethod paymentMethod
    }) async {
      try {
        final paymentIntent = await this._crearPaymentIntent(amount: amount, currency: currency);
        final paymentResult = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
            clientSecret: paymentIntent.clientSecret,
            paymentMethodId: paymentMethod.id,
          )
        );
        if(paymentResult.status == 'succeeded'){
          return StripeCustomResponse(
            ok: true
          );
        }else{
          return StripeCustomResponse(
            ok: false,
            msg: "Fallo: ${paymentResult.status}"
          );
        }
      } catch (e) {
        return StripeCustomResponse(
          ok: false,
          msg: e.toString()
        );  
      }
    }
}