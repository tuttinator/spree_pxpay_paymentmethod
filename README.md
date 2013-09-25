# Spree PxPay Gateway

This is a gem for Spree 2.0.3 which adds PXPay (paymentexpress.com - a NZ and
Australian Payment Processor) as a Payment Method.

This is does not use Active Merchant - this is not the version of the gateway
with a POST API (see ActiveMerchant PXPost docs), PXPay is the service hosted
on the Payment Express servers and credit card information is never touched by
your Spree implementation (sort of like PayPal's Website Payments system).

This extension will completely replace the payment page of the cart, and will
return the customer to the completed order page when their payment has been
processed.

As such, you can not use multiple payment methods (on the front end) alongside
this. You can manually create payments on the back-end as per usual.

## Installation

 1. Add the gem to your Gemfile
 2. `bundle install`
 3. Add a new Payment Method in the admin section using the `Spree::Gateway::PxPay`
 4. Set the relevant configuration details

## TODO

The DPS documentation talks of being able to embed as an iframe. I'd like to
see if it is possible within Spree's checkout process somewhere. Have to look
into the states within the state machine, I imagine.

Specs, obviously ;)

## THANKS

Inspired by the [spree-hosted-gateway gem](https://github.com/joshmcarthur/spree-hosted-gateway) and the work done by
@bradleypriest who wrote the [PXPay gem](https://github.com/bradleypriest/pxpay).
