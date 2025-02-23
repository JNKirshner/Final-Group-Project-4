library(fpp3)
library(tsibble)
library(seasonal)


#cleaning the data
credit <- read.csv('credit.csv')

credit$month <- 492:1

credit$month <- yearmonth(credit$month)

credit_ts <- tsibble(credit, index = month)

autoplot(credit_ts)
gg_season(credit_ts)

#Trying different models
#ARIMA
fit <- credit_ts %>% 
model(arima210 = ARIMA(ï..credit_in_millions ~ pdq(2,1,0)),
      arima013 = ARIMA(ï..credit_in_millions ~ pdq(0,1,3)),
      stepwise = ARIMA(ï..credit_in_millions),
      search = ARIMA(ï..credit_in_millions, stepwise=FALSE))

glance(fit) %>% arrange(AICc)


fit <- credit_ts %>% 
  model(ARIMA())

report(fit)

fit %>% forecast(h = 12) %>% 
  autoplot(credit_ts)

credit_train <- head(credit_ts, nrow(credit_ts) - 180)

credit_test <- tail(credit_ts, 180)


fit <- credit_train %>%
  model (
    Mean = MEAN(),
    `Naïve` = NAIVE(),
    `Seasonal naïve` = SNAIVE(),
    Drift = RW( ~ drift()),
    tslm = TSLM(~trend()),
    ets = ETS(),
    arima210 = ARIMA(ï..credit_in_millions ~ pdq(2,1,0)),
    arima013 = ARIMA(ï..credit_in_millions ~ pdq(0,1,3)),
    stepwise = ARIMA(ï..credit_in_millions),
    search = ARIMA(ï..credit_in_millions, stepwise=FALSE)
)

fit_fc <- fit %>%
  forecast(h = 12)

accuracy(fit_fc, credit_ts) %>% 
  arrange(RMSE)

fit %>%
  forecast(credit_test) %>%
  autoplot(credit_test)

fit %>%
  forecast(credit_test) %>%
  autoplot(credit_ts)

fit_fc_final <- fit %>%
  select(ets) %>% 
  forecast(h = 12)

accuracy(fit_fc_final, credit_ts) 

write.csv(fit_fc_final, "predictions.csv", row.names = FALSE)


fit %>% 
  select(tslm) %>% 
  forecast(h=12) %>% 
  autoplot(credit_ts)

fit %>% 
  select(`Seasonal naïve`) %>% 
  forecast(h=12) %>% 
  autoplot(credit_ts)

fit %>% 
  select(stepwise) %>% 
  forecast(h=12) %>% 
  autoplot(credit_ts)

fit %>% 
  select(search) %>% 
  forecast(h=12) %>% 
  autoplot(credit_ts)

fit %>% 
  select(ets) %>% 
  forecast(h=12) %>% 
  autoplot(credit_ts)

fit %>% 
  select(tslm) %>% 
  forecast(h=12) %>% 
  autoplot(credit_train)

fit %>% 
  select(`Seasonal naïve`) %>% 
  forecast(h=12) %>% 
  autoplot(credit_train)

fit %>% 
  select(stepwise) %>% 
  forecast(h=12) %>% 
  autoplot(credit_train)

fit %>% 
  select(search) %>% 
  forecast(h=12) %>% 
  autoplot(credit_ts)

fit %>% 
  select(ets) %>% 
  forecast(h=12) %>% 
  autoplot(credit_train)

