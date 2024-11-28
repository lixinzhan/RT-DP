# Unable to run RapidArc QA plans in File mode on TrueBeam - plans are unapproved

_KB000039102_

Applies to :
TrueBeam 2.0 - 2.7

### Symptoms :

    RapidArc QA test plans downloaded from myvarian.com
    Plans loaded in File mode on TrueBeam
    A message displays indicating the plan will be deactivated after loading the plan in File Mode.
    Another message indicates the plans are unapproved


### Resolution :

The RapidArc QA test plan are not approved.

    In TrueBeam there is a setting that controls the ability to load Unapproved plans in File Mode.
    From the Major Mode screen at TrueBeam;

    System Administration
    Treatment tab
    Clinical
    Ensure Allow Unapproved Plans - is set to Yes. This means that plans with unapproved status can be loaded in File mode. If treating patients in File Mode you would want have this option most likely set to NO to prevent any plan that was not approved from being treated.

 

 

### As a workaround:

    Import plans
    Approve plans
    Export plans
