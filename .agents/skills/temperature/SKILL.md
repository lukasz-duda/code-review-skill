---
name: temperature
description: Give temperature in Warsaw.
---

Example usage:

```
Give temperature.
```

Execute the curl command to fetch the current temperature in Warsaw from the Open-Meteo API:

```bash
curl -s "https://api.open-meteo.com/v1/forecast?latitude=52.2297&longitude=21.0122&current=temperature_2m" \
  | jq -r '(.current.temperature_2m | tostring) + " " + .current_units.temperature_2m'
```
