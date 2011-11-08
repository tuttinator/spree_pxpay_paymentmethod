Rails.application.routes.draw do
  match '/checkout/dps_callback' => 'checkout#dps_callback'
end