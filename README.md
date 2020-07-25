# Iex

This package is a Julia wrapper for the IEX Cloud API. IEX Cloud provides
realtime and historical data for commodities, equities, digital 
currencies (i.e. cryptocurrencies), foreign exchange etc.

The pricing structure is flexible and scalable, depending on
usage measured in terms of messages/month. Each API call has
a pre-specified message weight which is debited from the current
available message quota for the month.

The free tier level provides 50,000 core messages/month,
unlimited Investors Exchange data, unlimited sandbox testing,
and limited access to core data. A new account can be
established [here](https://iexcloud.io/cloud-login#/register).
