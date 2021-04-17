use prihodi

SELECT OsobaID, PrezIme,Ime, PoslodavacID FROM Osoba

SELECT OsobaID, PrezIme,Ime FROM Osoba WHERE Spol='M'

SELECT * FROM PolisaOsiguranja WHERE VrijednostPolise >750 ORDER BY VrijednostPolise ASC

SELECT RedovniPrihodiID, Neto FROM RedovniPrihodi WHERE Neto<=600 ORDER BY Neto DESC


SELECT VanredniPrihodiID,IznosVanrednogPrihoda, DatumObracuna FROM VanredniPrihodi WHERE Godina=2016 AND Mjesec<7 ORDER BY DatumIsplate ASC


SELECT RedovniPrihodiID, Neto FROM RedovniPrihodi WHERE KlasaRedPrihoda_Neto=3 AND (Mjesec>6 AND Godina=2017) ORDER BY Neto ASC


SELECT RedovniPrihodiID, (Bruto-Neto) AS Doprinosi FROM RedovniPrihodi WHERE (Bruto - Neto)>300  AND (Bruto - Neto)<400  ORDER BY 2


SELECT VanredniPrihodiID,IznosVanrednogPrihoda, 'PREKORACENJE' FROM VanredniPrihodi WHERE BrojDanaRazlike>3 

SELECT PolisaID, VrijednostPolise, IznosRate,DatumIzdavanja FROM PolisaOsiguranja WHERE
 IznosRate>75 OR (YEAR(DatumIzdavanja)=2018 AND MONTH(DatumIzdavanja)>9) ORDER BY 4


SELECT RedovniPrihodiID, (Zdravstveno+Penzijsko) AS Doprinosi FROM RedovniPrihodi WHERE 
((Zdravstveno+Penzijsko)>750 and (Zdravstveno+Penzijsko)<1000) AND Kvartal>2 ORDER BY 2