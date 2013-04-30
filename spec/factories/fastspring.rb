FactoryGirl.define do

  factory :activate, class: Hash do

    SubscriptionCustomerUrl "https://sites.fastspring.com/pxiio/order/s/PXI130225-1517-78138S"
    SubscriptionEndDate ""
    SubscriptionReference "PXI130225-1517-66135S"
    SubscriptionReferrer "8"
    ProductPath "/funplan"
    SubscriptionQuantity "1"
    
    SubscriptionNextPeriodDate "2013-05-01"
    SubscriptionStatus "active"
    SubscriptionStatusReason "new subscription message"
    SubscriptionTotalPriceCurrency "GBP"
    SubscriptionTotalPriceValue "5.0"
    
    security_data "13617967245321361796724521"
    security_hash "7a2908bb4397fea4402c2406d54bd60f"

    initialize_with { attributes }
  end

  factory :changed, class: Hash do
    ProductPath "/eventplan"
    SubscriptionReference "PXI130225-1517-66135S"
    SubscriptionStatusReason ""
    SubscriptionReferrer "8"
    SubscriptionEndDate ""
    SubscriptionCustomerUrl "https://sites.fastspring.com/pxiio/order/s/PXI130225-1517-20159S"
    SubscriptionQuantity "1"
    SubscriptionStatus "active"
    SubscriptionTotalPriceCurrency "GBP"
    SubscriptionTotalPriceValue "53.0"

    initialize_with { attributes }
  end

  factory :cancelled, class: Hash do
    ProductPath "/proplan"
    SubscriptionReference "PXI130225-1517-66135S"
    SubscriptionStatusReason "canceled"
    SubscriptionReferrer "8" 
    SubscriptionEndDate (Date.today + 30.days)
    SubscriptionCustomerUrl "https://sites.fastspring.com/pxiio/order/s/PXI130225-1517-20159S"
    SubscriptionQuantity "1"
    SubscriptionStatus "active"
    SubscriptionTotalPriceCurrency "GBP"
    SubscriptionTotalPriceValue "16.50"

    intialize_with { attributes }
  end

  factory :deactivated, class: Hash do
    SubscriptionCustomerUrl "https://sites.fastspring.com/pxiio/order/s/PXI130225-1517-20159S"
    SubscriptionEndDate Date.today
    SubscriptionQuantity "1"
    SubscriptionReference "PXI130225-1517-66135S"
    SubscriptionReferrer "8"

    initialize_with { attributes }
  end

end
