# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spree_pxpay_paymentmethod/version"

Gem::Specification.new do |s|
  s.name        = "spree_pxpay_paymentmethod"
  s.version     = SpreePxpayPaymentmethod::VERSION
  s.authors     = ["tuttinator"]
  s.email       = ["caleb.tutty@gmail.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "spree_pxpay_paymentmethod"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_dependency('spree_core', '>= 0.70.0')
  s.add_dependency('pxpay')
  
end
