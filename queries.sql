-- ========================================================
-- E-COMMERCE CUSTOMER ANALYTICS & ADVANCED SEGMENTATION
-- Database: MariaDB / MySQL
-- Author: Marcin Paweloszek
-- ========================================================

-- 1. RAPORT KOHORTOWY: DYNAMIKA KOSZYKA I RETENCJA CZASOWA POWROTÓW
WITH historia_pelna AS (
    SELECT 
        klient,
        kwota,
        data_zamowienia,
        COALESCE(
            DATEDIFF(data_zamowienia, LAG(data_zamowienia) OVER (PARTITION BY klient ORDER BY data_zamowienia)),
            0
        ) AS dni_od_poprzedniego,
        COALESCE(
            kwota - LAG(kwota) OVER (PARTITION BY klient ORDER BY data_zamowienia),
            0
        ) AS roznica_koszyka
    FROM zamowienia
    WHERE data_zamowienia IS NOT NULL
)
SELECT 
    klient,
    COUNT(*) AS lacznie_zamowien,
    SUM(kwota) AS ltv_calkowite,
    ROUND(AVG(kwota), 2) AS sredni_koszyk,
    MIN(CASE WHEN dni_od_poprzedniego > 0 THEN dni_od_poprzedniego END) AS min_dni_powrotu,
    MAX(CASE WHEN dni_od_poprzedniego > 0 THEN dni_od_poprzedniego END) AS max_dni_powrotu,
    ROUND(AVG(CASE WHEN dni_od_poprzedniego > 0 THEN roznica_koszyka END), 2) AS sredni_wzrost_koszyka
FROM historia_pelna
GROUP BY klient
HAVING COUNT(*) > 1
ORDER BY ltv_calkowite DESC;


-- 2. MODELOWANIE I SEGMENTACJA RFM (RECENCY, FREQUENCY, MONETARY)
WITH rfm_bazowe AS (
    SELECT 
        klient,
        DATEDIFF('2026-10-29', MAX(data_zamowienia)) AS recency_dni,
        COUNT(*) AS frequency_zamowienia,
        SUM(kwota) AS monetary_ltv
    FROM zamowienia
    WHERE data_zamowienia IS NOT NULL
    GROUP BY klient
),
rfm_scores AS (
    SELECT 
        klient,
        recency_dni,
        frequency_zamowienia,
        monetary_ltv,
        NTILE(3) OVER (ORDER BY recency_dni DESC) AS r_score,
        NTILE(3) OVER (ORDER BY frequency_zamowienia ASC) AS f_score,
        NTILE(3) OVER (ORDER BY monetary_ltv ASC) AS m_score
    FROM rfm_bazowe
)
SELECT 
    klient,
    monetary_ltv,
    CONCAT(r_score, '-', f_score, '-', m_score) AS profil_rfm,
    CASE 
        WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Czempion VIP'
        WHEN f_score = 3 AND m_score >= 2 THEN 'Lojalny Klient'
        WHEN r_score = 1 AND f_score >= 2 THEN 'Zagrożony Odejściem'
        WHEN r_score >= 2 AND f_score = 1 AND m_score >= 2 THEN 'Nowy o Wysokim Potencjale'
        WHEN r_score = 3 AND f_score = 1 THEN 'Świeży Klient'
        ELSE 'Klient Uśpiony'
    END AS segment_biznesowy
FROM rfm_scores
ORDER BY monetary_ltv DESC;


-- 3. EXECUTIVE SUMMARY: PODSUMOWANIE PRZYCHODÓW PER SEGMENT BIZNESOWY
WITH rfm_bazowe AS (
    SELECT 
        klient,
        DATEDIFF('2026-10-29', MAX(data_zamowienia)) AS recency_dni,
        COUNT(*) AS frequency_zamowienia,
        SUM(kwota) AS monetary_ltv
    FROM zamowienia
    WHERE data_zamowienia IS NOT NULL
    GROUP BY klient
),
rfm_scores AS (
    SELECT 
        klient,
        monetary_ltv,
        NTILE(3) OVER (ORDER BY recency_dni DESC) AS r_score,
        NTILE(3) OVER (ORDER BY frequency_zamowienia ASC) AS f_score,
        NTILE(3) OVER (ORDER BY monetary_ltv ASC) AS m_score
    FROM rfm_bazowe
),
rfm_segmenty AS (
    SELECT 
        klient,
        monetary_ltv,
        CASE 
            WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Czempion VIP'
            WHEN f_score = 3 AND m_score >= 2 THEN 'Lojalny Klient'
            WHEN r_score = 1 AND f_score >= 2 THEN 'Zagrożony Odejściem'
            WHEN r_score >= 2 AND f_score = 1 AND m_score >= 2 THEN 'Nowy o Wysokim Potencjale'
            WHEN r_score = 3 AND f_score = 1 THEN 'Świeży Klient'
            ELSE 'Klient Uśpiony'
        END AS segment_biznesowy
    FROM rfm_scores
)
SELECT 
    segment_biznesowy,
    COUNT(*) AS liczba_klientow,
    SUM(monetary_ltv) AS przychod_segmentu,
    ROUND(AVG(monetary_ltv), 2) AS srednie_ltv,
    ROUND(SUM(monetary_ltv) / (SELECT SUM(kwota) FROM zamowienia WHERE data_zamowienia IS NOT NULL) * 100, 2) AS udzial_procentowy_przychodow
FROM rfm_segmenty
GROUP BY segment_biznesowy
ORDER BY przychod_segmentu DESC;
