Pricing:
Calculate On either of these: 
    https://aws.amazon.com/pricing/
    https://calculator.aws/

My calculated expenses:
https://calculator.aws/#/estimate?id=96d70d812771b2578992d1b3770e6368bc17f412


Explanation:

VPC: .0045$ per gig, and no Nat gateways, so very low amount of data so this is negligible
Lambda: About .01$ per month per user
API Gateway: About .01$ per month per user

Aurora Serverless v2: 
    Explanation: .5 acu per hour, which should mean you get enough to write constantly for a lot of people (hard to calculate, but it should be fine for a few hundred to even a few thousand I believe).
    Cost is around 44$ a month, if it never sleeps (it is set to drop down to 0 if idle, which can reduce costs)
    I recommend that in Production you change lowest ACU to at least .5 so it never sleeps.