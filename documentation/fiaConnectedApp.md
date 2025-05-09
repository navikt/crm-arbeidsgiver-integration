# Salesforce-Fia Connected App-oppsett

Denne dokumentasjonen beskriver oppsett og bruk av Salesforce Connected App for Fia-integrasjonen. Den dekker OAuth‑policy, autentisering, tilgangskontroll, eksempler på API‑kall, integrasjonsbrukere, Connected Apps og konfigurasjon i ulike miljøer.

## OAuth-policy

For å bruke OAuth Username-Password Flow må følgende innstilling være aktivert i Salesforce:

-   "Tillat OAuth Username‑Password Flows" må være aktivert i organisasjonens OAuth-innstillinger.

## 2. Token‑URL

| Miljø           | Token‑URL                                |
| --------------- | ---------------------------------------- |
| Preprod / SIT‑2 | `https://test.salesforce.com`            |
| Produksjon      | `https://navdialog.lightning.force.com/` |

---

## OAuth-parametre

Når du henter access token, send disse form‑parametrene:

| Parameter       | Verdi/Beskrivelse                                                     |
| --------------- | --------------------------------------------------------------------- |
| `grant_type`    | `password`                                                            |
| `client_id`     | Consumer Key fra Connected App → “View” → API (Enable OAuth Settings) |
| `client_secret` | Consumer Secret                                                       |
| `username`      | Integrasjonsbrukerens brukernavn                                      |
| `password`      | Integrasjonsbrukerens passord + sikkerhetstoken                       |

## 5. Eksempler på API‑kall / SOQL‑spørringer

### 5.1 HTTP GET:

```http
GET https://navdialog--sit2.sandbox.my.salesforce.com/services/data/v63.0/query?
```

### 5.2 Account:

```sql
SELECT Id,
       INT_OrganizationNumber__c,
       TAG_Partner_Status__c
FROM Account
WHERE INT_OrganizationNumber__c = '123456789'
```

### 5.3 IACooperation\_\_c:

```sql
SELECT Id
FROM IACooperation__c
WHERE CooperationId__c = '1234'
```

## 6. Integrasjonsbrukere for Fia

| Miljø      | Brukernavn                            |
| ---------- | ------------------------------------- |
| SIT‑2      | fia.integrasjonsbruker@nav.no.sit2    |
| Preprod    | fia.integrasjonsbruker@nav.no.preprod |
| Produksjon | fia.integrasjonsbruker@nav.no         |

---

## 7. Permission Set

Tildel følgende Permission Set til integrasjonsbrukeren:

-   **Arbeidsgiver ‑ Fia Integrasjonsbruker**  
    Gir tilgang til nødvendige felt på objektene `Account` og `IACooperation__c`.

---

## 8. Connected Apps

| Miljø      | App‑navn          |
| ---------- | ----------------- |
| SIT‑2      | Kafka Integration |
| Preprod    | Kafka Integration |
| Produksjon | Fia Integration   |

---

## 9. Eksempel: Token‑uthenting i Kotlin

```kotlin
val response = httpClient.submitForm( url = tokenUrl, formParameters = parameters { append("grant_type", "password") append("client_id", salesforceKonfig.clientId) append("client_secret", salesforceKonfig.clientSecret) append("username", salesforceKonfig.username) append("password", salesforceKonfig.password + salesforceKonfig.securityToken) }, )
```

Security Token hentes eller nullstilles fra integrasjonsbrukerens Salesforce‑innstillinger.

## 10. Merknader

-   **Husk å sjekke at integrasjonsbrukeren har riktig tilgang til private records via Sharing Settings** (for eksempel Account‑records).
