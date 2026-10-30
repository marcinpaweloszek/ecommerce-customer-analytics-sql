# 🛒 E-Commerce Customer Analytics & Advanced Segmentation (SQL)

Kompleksowe studium przypadku analityki e-commerce oparte na danych transakcyjnych MariaDB/MySQL. Projekt łączy inżynierię zaawansowanych zapytań SQL z analizą biznesową: wielowymiarową retencją kohortową, dynamiką wartości koszyka oraz segmentacją klientów w modelu RFM (Recency, Frequency, Monetary).

---

## 🎯 1. Cel biznesowy projektu
Celem projektu była diagnoza efektywności retencyjnej sklepu internetowego oraz optymalizacja alokacji budżetu marketingowego poprzez:
* Identyfikację kluczowych kohort powracających i wyznaczenie optymalnego okna re-engagementu.
* Ewaluację dynamiki koszyka zakupowego ($LTV$ i $AOV$).
* Statystyczną segmentację bazy klientów metodą RFM w celu rekomendacji działań CRM i maksymalizacji przychodu.

---

## 🛠️ 2. Zastosowany Stack Technologiczny i Metodologia
* **Baza danych:** MariaDB 11.x / Ubuntu Linux (VPS Hetzner)
* **Złożona architektura SQL:**
  * Wielopoziomowe tabele wirtualne CTE (`WITH`) eliminujące zbędne zapytania tymczasowe.
  * Funkcje przesunięcia okna (`LAG()`, `LEAD()`) do śledzenia indywidualnej trajektorii zakupowej klienta w czasie.
  * Podział statystyczny (`NTILE(3)`) pozwalający na obiektywny scoring bez sztucznych progów arbitralnych.
  * Zaawansowane agregacje warunkowe (`CASE WHEN` wewnątrz `MIN/MAX`) oraz obsługa braków (`COALESCE`) eliminujące błędy typu "fałszywe zero".

---

## 📊 3. Kluczowe Wyniki Analizy

### A. Raport Kohortowy i Dynamika Koszyka
Zestawienie klientów powracających pod kątem dynamiki ich wydatków oraz tempa powrotu:

| Klient | Wolumen transakcji | LTV całkowite | Średni koszyk (AOV) | Okno powrotu (dni) | Średni wzrost koszyka |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Piotr Wiśniewski** | 2 | 1750.20 zł | 875.10 zł | 11 | **+149.80 zł** |
| **Jan Kowalski** | 2 | 1350.00 zł | 675.00 zł | 7 | **+150.00 zł** |
| **Marta Nicpoń** | 2 | 1240.00 zł | 620.00 zł | 17 | **+560.00 zł** |
| **Dominik Grajewski** | 2 | 1130.00 zł | 565.00 zł | 3 | **+470.00 zł** |
| **Mateusz Ryglicki** | 2 | 1120.00 zł | 560.00 zł | 1 | **+680.00 zł** |
| **Agata Nowak** | 2 | 1020.00 zł | 510.00 zł | 1 | **+580.00 zł** |
| **Anna Czeczotka** | 2 | 980.00 zł | 490.00 zł | 27 | **+320.00 zł** |

> **Wniosek:** 100% klientów powracających wygenerowało dodatnią dynamikę koszyka (średni wzrost od +149.80 zł do +680.00 zł). Najbardziej wartościowa grupa powraca błyskawicznie w oknie 1–3 dni.

---

### B. Segmentacja RFM (Recency, Frequency, Monetary)
Podsumowanie zagregowane bazy klientów w podziale na segmenty behawioralne:

| Segment biznesowy | Liczba klientów | Przychód segmentu | Średnie LTV | Udział w przychodach |
| :--- | :---: | :---: | :---: | :---: |
| **Lojalny Klient** | 5 | **5 670.20 zł** | 1 134.04 zł | **35.11%** |
| **Klient Uśpiony** | 11 | **4 190.00 zł** | 380.91 zł | **25.94%** |
| **Czempion VIP** | 3 | **3 350.00 zł** | 1 116.67 zł | **20.74%** |
| **Nowy o Wysokim Potencjale** | 4 | **2 150.00 zł** | 537.50 zł | **13.31%** |
| **Zagrożony Odejściem** | 3 | **790.00 zł** | 263.33 zł | **4.89%** |

> **Wniosek (Zasada Pareto):** Zaledwie 8 klientów (Czempioni VIP + Lojalni) generuje **55.85% łącznego przychodu sklepu** (9 020.20 zł z 16 150.20 zł).

---

## 💡 4. Rekomendacje Strategiczne (Actionable Insights)
1. **Retencja "Hot-Window" (1–3 dni):** Zbudowanie automatycznej sekwencji onboardingowej dla segmentu *Nowy o Wysokim Potencjale* uruchamianej w ciągu 48h od pierwszego zakupu w celu stymulacji drugiego koszyka.
2. **Program VIP (Ochrona Czempionów i Lojalnych):** Dedykowana linia wsparcia i priorytetowa logistyka dla segmentów odpowiadających za >55% obrotu.
3. **Aktywacja segmentu Zagrożonego:** Wykorzystanie kampanii rabatowych typu *win-back* z ograniczeniem czasowym dla klientów, których `recency` przekracza średnią bazy.

---

## 💻 5. Struktura Zapytań SQL
Pełny skrypt zapytań analitycznych znajduje się w pliku `queries.sql`.
