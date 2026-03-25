# Opis sloga osobnog računa pomagala

## Uvod

[Hrvatski zavod za zdravstveno osiguranje uvodi novu funkcionalnost na
Portalu HZZO eZdravstveno.]{.mark}

[Omogućena je dostava računa za ortopedska pomagala kroz razmjenu
podataka na Portalu.]{.mark}

[Za isporučitelje ortopedskih pomagala početak rada novog sustava u
primjeni je od 21.4.2025.]{.mark}

[Preporuka je Zavoda da se radi kontinuirane i ujednačene raspodjele
prihvata i obrade računa, isti dostavljaju učestalije, odnosno na
tjednoj razini.]{.mark}

[Prihvat računa na magnetskim medijima bit će omogućen do kraja
2025.godine osim u izvanrednim okolnostima.]{.mark}

Računi za pomagala od isporučitelja preuzimaju se na magnetskom mediju
(na standardnoj 3,5\" disketi, HD (high-density) format, CD, DVD, USB).
Svi računi zajedno s prilozima pohranjuju se na medij u jednu
nekomprimiranu [tekstualnu]{.underline} datoteku u kojoj se nalaze reci
s podacima. Datoteka na mediju treba imati ime
***aaabbbbbbbbbcccc.Ozz*** gdje *aaa* označava šifru nadležne područne
službe (s uključenom vodećom nulom, odnosno 2 vodeće nule za PU
Bjelovar), *bbbbbbbbb* predstavlja šifru isporučitelja, a *cccc* redni
broj datoteke unutar jedne godine. U ekstenziji O*zz* *zz* označava
godinu a O je oznaka za Ortopedska pomagala (Npr. naziv
**0601234567890020.O16** označava dvadesetu datoteku isporučitelja
123456789, koja pripada RU Osijek, u 2016. godini.)**.** Istu oznaku
treba imati i magnetski medij.

Ako ustanova odjednom ispostavlja više podataka nego što dozvoljava
kapacitet jednog medija, podatke pohranjuje na više medija s time da
podaci jednog računa sa stavkama [moraju]{.underline} biti na jednom
mediju, tj. nije dozvoljeno da se podaci nastavljaju s jednog medija na
drugi.

Isporučitelj ortopedskih pomagala, predaje u PU podatke o izvršenim
uslugama u papirnatom obliku i na magnetskom mediju. Uz svaki takav
komplet mora biti i popratni dopis (opis sadržaja medija). **Jedan
komplet čine jedan ili više računa, popratni dopis i medij na kojem su
svi računi.** U dopisu moraju biti sljedeći podaci:

1.  šifra i naziv isporučitelja koja šalje račun,

```{=html}
<!-- -->
```
1.  datum formiranja medija,

```{=html}
<!-- -->
```
1.  oznaka medija yyy/zzz (redni broj medija u godini/godina),

```{=html}
<!-- -->
```
1.  žiro račun isporučitelja,

```{=html}
<!-- -->
```
1.  ukupni broj računa,

```{=html}
<!-- -->
```
1.  suma ukupnih iznosa sa svih računa (iznos na teret HZZO-a),

```{=html}
<!-- -->
```
1.  popis brojeva računa.

Svaki medij mora imati labelu (etiketu) na kojoj će isporučitelj upisati
sljedeće podatke:

1.  šifra i naziv isporučitelja koja šalje račun,

```{=html}
<!-- -->
```
1.  datum formiranja medija,

```{=html}
<!-- -->
```
1.  oznaka medija yyy/zzz (redni broj medija u godini/godina).

[Redovi datoteke:]{.underline}

1.  Slog računa (jedan redak)

-   Stavke izdanih pomagala (jedan ili više redaka)

1.  Slog računa (jedan redak)

2.  Stavke izdanih pomagala (jedan ili više redaka)

```{=html}
<!-- -->
```
1.  Slog računa (jedan redak)

2.  Stavke izdanih pomagala (jedan ili više redaka)

```{=html}
<!-- -->
```
1.  ...

Redovi u datoteci su odijeljeni standardnom DOS oznakom kraja retka
CR/LF (decimalni ASCII kodovi  13  i  10).

Tekstualni podaci u svakom retku upisani su [bez]{.underline} vodećih i
završnih razmaka, brojčani podaci su upisani [bez]{.underline} vodećih
nula osim ako podatak predstavlja šifru ili izričito nije navedeno, a
međusobno su odijeljeni *[delimiterom]{.underline}*, tj. znakom koji
označava kraj jednog i početak drugog podatka unutar retka.

Standardni delimiter je znak dvotočka (\"**:**\" , decimalni ASCII  kod
 58). Taj znak je jedini dozvoljeni delimiter u cijeloj datoteci i ne
smije biti dio bilo kojeg podatka u datoteci (npr. ne smije se
pojavljivati u broju računa isporučitelja).

Format (izgled) podataka u redovima datoteke određen je specifikacijom u
nastavku.

U opisu formata (izgleda) podataka nalaze se sljedeće oznake:

> A(n) - točno n puta slovo (A - Z)
>
> N(n) - točno n puta broj (0 - 9)
>
> AN(n) - točno n puta slovo (A - Z) ili broj (0 - 9)
>
> A(max n) - najviše n puta slovo (A - Z)
>
> N(max n) - najviše n puta broj (0 - 9)
>
> AN(max n) - najviše n puta slovo (A - Z) ili broj (0 - 9)
>
> NS(max n) - najviše n puta broj (0 - 9) ili znak \"**/**\" ili znak
> \"**-**\"
>
> ANS(max n) - najviše n puta slovo (A - Z) ili broj (0 - 9) ili znak
> \"**/**\" ili znak \"**-**\"
>
> znak \... - fiksno navedeni znak (slovo)
>
> [Napomena:]{.underline}\
> Pod slovima (A - Z) podrazumijevaju se samo slova
> [internacionalne]{.underline} abecede, osim u podatku *Naziv
> isporučitelja*, gdje se uz slova internacionalne abecede mogu
> koristiti naglašeni suglasnici zapisani prema međunarodnom standardu
> **ISO 8859-2.**

[Računi i propisani prilozi šalju se digitalno potpisani putem HZZO
eZdravstveno Portala.]{.mark}

[Svaka dostava računa obavezno sadrži datoteku za učitavanje podataka
računa (unl datoteka) i pdf tiskanicu računa a prilozi ovise o vrsti
potvrde na koju se račun odnosi.]{.mark}

[Na portalu se provodi **kontrola strukture naziva datoteke** te
**ispravnost digitalnog** **potpisa**. Samo jedna datoteka ili
nepotpisana datoteka tretira se kao pogreška i ne ulazi u daljnju
obradu.]{.mark}

[Struktura naziva datoteka RAČUNA ( unl + PDF tiskanica računa) mora
imati propisani oblik, a nazivi priloga su proizvoljni.]{.mark}

[Struktura naziva datoteka mora imati slijedeći oblik:]{.mark}

> [AAA_Rn_BBBBBBBBBCCCC.OGG.p7m]{.mark}
>
> [AAA_Rn_BBBBBBBBBCCCC.OGG.pdf.p7m]{.mark}

[Prilog1.pdf.p7m]{.mark}

[Prilog2.pdf.p7m]{.mark}

[gdje su:]{.mark}

[AAA -- šifra nadležne Područne ustrojstvene jedinice]{.mark}

[Rn -- konstanta]{.mark}

[BBBBBBBBB -- šifra ustanove/ordinacije koja šalje račun]{.mark}

[CCCC -- redni broj datoteke u godini]{.mark}

[O -- konstanta koja označava da se radi o računima za pomagala]{.mark}

[GG -- godina]{.mark}

[p7m / p7s -- oznaka digitalnog potpisa]{.mark}

[Od 21.4.2025. će biti podržan prihvat potpisanih datoteka u p7s i p7m
obliku.]{.mark}

[Za osobe kategorije T - računi koje plaća Ministarstvo zdravstva,
datoteke imaju strukturu naziva:]{.mark}

> [AAA_Rn_BBBBBBBBBCCCCT.OGG.p7m]{.mark}
>
> [AAA_Rn_BBBBBBBBBCCCCT.OGG.pdf.p7m]{.mark}

[gdje je T fiksna oznaka, a ostali elementi kao i kod računa koje plaća
HZZO]{.mark}

##  Vodeći slog osobnog računa pomagala

Slog računa prethodi svojim stavkama, a sadrži sljedeće podatke:

+----+-------------------------+-----------------------+-------+---+-----+
| Re | Opis podatka            | Format (izgled) ili   | Ob    |   | Pr  |
| d. |                         | sadržaj polja         | vezan |   | ovj |
| b  |                         |                       | po    |   | era |
| r. |                         |                       | datak |   |     |
+====+=========================+=======================+=======+===+=====+
| 1. | Identifikator sloga     | znak \"**60**\"       | Da    |   |     |
|    |                         |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 2. | **Šifra isporučitelja** | N9                    | Da    |   | K   |
|    |                         |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 3. | **Naziv isporučitelja** | AN (max 45)           | Da    |   |     |
|    |                         |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 4. | **Broj ovjerene         | N(max3) + znak        | *     |   | **  |
|    | potvrde**               | \"/\" + N(max10)      | *Ne^1 |   | K** |
|    |                         |                       | ,3^** |   |     |
|    |                         | Primjer: 88/87310581  |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 5. | **Datum obračuna**      | N2 + znak \".\" +     | *     |   | **  |
|    |                         | N2 + znak \".\" + N4\ | *Da** |   | K** |
|    |                         | Primjer: 13.03.2022   |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 6. | Vrsta pomagala          | N1- Moguće            | Da    |   | K   |
|    | /tiskanice              | vrijednosti:          |       |   |     |
|    |                         | 1,2,3,4,5,7 ili 8     |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 7. | Datum narudžbe pomagala | N2 + znak \".\" +     | Da    |   | K   |
|    |                         | N2 + znak \".\" + N4\ |       |   |     |
|    |                         | Primjer: 13.03.2022   |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 8. | Broj osobnog računa     | ANS (max 22)          | Da, u |   |     |
|    | isporučitelja za        |                       | sl    |   |     |
|    | dopunsko osiguranje     |                       | učaju |   |     |
|    |                         |                       | dop.  |   |     |
|    |                         |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 9. | Broj police/iskaznice   | N(8)                  | Da, u |   | K   |
|    | dopunskog osiguranja    |                       | sl    |   | ^2^ |
|    |                         |                       | učaju |   |     |
|    |                         |                       | dop.  |   |     |
|    |                         |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 10 | Ukupni iznos za         | N (max 9) + znak      | Da    |   | K   |
| .  | pomagala\*\*            | \"**.**\" + N2        |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 11 | Iznos sudjelovanja      | N (max 9) + znak      | Da    |   |     |
| .  | osigurane osobe         | \"**.**\" + N2\       |       |   |     |
|    |                         | (ukoliko ne postoji,  |       |   |     |
|    |                         | upisuje se 0.00)      |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 12 | Iznos na teret          | N (max 9) + znak      | Da, u |   |     |
| .  | dopunskog osiguranja    | \"**.**\" + N2\       | sl    |   |     |
|    | HZZO-a (sa PDV-om )     | (ukoliko ne postoji,  | učaju |   |     |
|    |                         | upisuje se 0.00)      | dop.  |   |     |
|    |                         |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 13 | Iznos PDV-a od          | N (max 9) + znak      | Da, u |   |     |
| .  | dopunskog osiguranja    | \"**.**\" + N2\       | sl    |   |     |
|    | HZZO-a                  | (ukoliko ne postoji,  | učaju |   |     |
|    |                         | upisuje se 0.00)      | dop.  |   |     |
|    |                         |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 14 | Iznos na teret obveznog | N (max 9) + znak      | Da    |   |     |
| .  | osiguranja HZZO-a (sa   | \"**.**\" + N2        |       |   |     |
|    | PDV-om )                |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 15 | Iznos PDV-a obračunatog | N (max 9) + znak      | Da    |   |     |
| .  | na teret obveznog       | \"**.**\" + N2\       |       |   |     |
|    | osiguranja              | (ukoliko ne postoji,  |       |   |     |
|    |                         | upisuje se 0.00)      |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 16 | Ne koristi se           | N8                    |       |   |     |
| .  |                         |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 17 | Ne koristi se           | N3                    |       |   |     |
| .  |                         |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 18 | Matični broj osigurane  | N9                    | Da\*  |   | K   |
| .  | osobe                   |                       |       |   | ^2^ |
+----+-------------------------+-----------------------+-------+---+-----+
| 19 | Broj bolesničkog lista  | N(max3) + znak        | Da,   |   | K   |
| .  | INO osig. osobe;        | \"/\" + N(max8);      | za    |   | ^2^ |
|    | Identifikacijski br. EU | AN(20)                | INO   |   |     |
|    | kartice zdr. osig.      |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 20 | Država osigurane osobe\ | A3                    | Da,   |   | K   |
| .  | (međunarodna troslovna  |                       | za    |   | ^2^ |
|    | šifra)                  |                       | INO   |   |     |
|    |                         |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 21 | Šifra proizvođača       | N10                   | N     | N |     |
| .  |                         |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 22 | Ukupan iznos            | N (max 9) + znak      | Da    |   |     |
| .  | fakturiranih postupaka  | \"**.**\" + N2\       |       |   |     |
|    | na teret HZZO (sa       | (ukoliko ne postoji,  |       |   |     |
|    | PDV-om ako postoji)     | upisuje se 0.00)      |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 23 | Ukupan iznos            | N (max 9) + znak      | Da, u |   |     |
| .  | fakturiranih postupaka  | \"**.**\" + N2\       | sl    |   |     |
|    | dopunskog ZO (sa PDV-om | (ukoliko ne postoji,  | učaju |   |     |
|    | ako postoji)            | upisuje se 0.00)      | dop.  |   |     |
|    |                         |                       | osig. |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 24 | Broj osobnog računa     | ANS (max 22)          | Da    |   |     |
| .  | isporučitelja           |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 25 | Aktivnost obveznog      | N7                    | Da    | K |     |
| .  | osiguranja              |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 26 | Aktivnost dopunskog     | N5                    | Ne    | K |     |
| .  | osiguranja HZZO-a       |                       |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 27 | Broj potvrde            | N14                   | Ne    | K |     |
| .  | ortopedskog pomagala    |                       | ^1,3^ |   |     |
|    | izabranog doktora       | Sastoji se od šifre   |       |   |     |
|    |                         | zd                    |       |   |     |
|    |                         | r.ustanove-ordinacije |       |   |     |
|    |                         | privatne prakse       |       |   |     |
|    |                         | (N9) + rednog broja   |       |   |     |
|    |                         | unutar godine (N4) +  |       |   |     |
|    |                         | kontrolni broj        |       |   |     |
|    |                         | izračunat po modelu   |       |   |     |
|    |                         | 11(N1)                |       |   |     |
|    |                         |                       |       |   |     |
|    |                         | Primjer:              |       |   |     |
|    |                         | 07730773900019        |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 28 | Identifikator ePotvrde  | ANS (max 100)         | Ne    |   |     |
| .  | (br. eOdobrenja)        |                       | ^1,3^ |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 29 | Datum izdavanja         | N2 + znak \".\" +     | Da    |   |     |
| .  | pomagala                | N2 + znak \".\" + N4\ |       |   |     |
|    |                         | Primjer: 01.05.2022   |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 30 | Ukupni iznos razlike u  | N (max 9) + znak      | Ne    |   |     |
| .  | cijeni \*\*\*           | \"**.**\" + N2        |       |   |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 31 | OIB\*                   | N(11)                 | Ne    | K |     |
| .  |                         |                       |       | ^ |     |
|    |                         |                       |       | 2 |     |
|    |                         |                       |       | ^ |     |
+----+-------------------------+-----------------------+-------+---+-----+
| 32 | Valuta                  | A(3)                  | Da    | K |     |
| .  |                         |                       |       | ^ |     |
|    |                         |                       |       | 7 |     |
|    |                         |                       |       | ^ |     |
+----+-------------------------+-----------------------+-------+---+-----+

Napomene:

-   Podaci pod rednim brojevima 8, 9, 11, 12 i 13 ne postoje na računima
    za pomagala izdana zbog ozljede na radu ili profesionalne bolesti te
    se ta polja neće kontrolirati. Polja 8 i 9 se ostavljaju prazna, a u
    polja 11, 12 i 13 se upisuje 0.

-   Podatak pod rednim brojem 7: datum narudžbe pomagala može biti max
    30 dana od datuma ovjere potvrde

-   Podatak pod rednim brojem 10 - ukupni iznos za pomagala je iznos
    koji se odnosi isključivo na trošak pomagala s potvrde ( iznos u
    kojem je i sudjelovanje osobe ili dopunsko osiguranje ali ne i iznos
    postupaka u ljekarni koji se iskazuje posebno u polju 22)

-   Podatak pod rednim brojem 21: polje se ostavlja prazno, podatak o
    proizvođaču se upisuje u stavkama Pomagala pod rednim brojem 7

-   Podaci sa \* - unosi se neki od podataka za identifikaciju
    osiguranika - MBO ili OIB tj podaci u poljima 18 i 31 ili podaci 19
    i 20 u slučaju INO osiguranika

-   \*\* U polje 10 upisuje se ukupna cijena pomagala sa PDV-om s
    Osnovne liste pomagala

-   \*\*\* U polje 30 upisuje se ukupna razlika u cijeni sa PDV-om za
    pomagala s dodatne Liste Pomagala (doplata koju plaća osiguranik)

## Stavke računa 

Stavke računa sadrže podatke o ovjerenim i izdanim pomagalima (sa
ovjerene potvrde).

Redci s podacima stavki moraju u datoteci slijediti neposredno nakon
vodećeg sloga pripadnog računa.

## Pomagala

+----+---------------------------+-----------------------+-------+----+
| R  | Opis podatka              | Format (izgled) ili   | Ob    | Pr |
| ed |                           | sadržaj polja         | vezan | ov |
| .b |                           |                       | po    | je |
| r. |                           |                       | datak | ra |
+====+===========================+=======================+=======+====+
| 1. | Identifikator sloga       | znak \"**61**\"       | Da    |    |
|    |                           |                       |       |    |
+----+---------------------------+-----------------------+-------+----+
| 2. | **Broj ovjerene potvrde** | **N(max3) + znak      | **Da  | K  |
|    |                           | \"/\" + N(max10)**    | ^1    |    |
|    |                           | Primjer: 88/87310581  | ,3^** |    |
+----+---------------------------+-----------------------+-------+----+
| 3. | **Datum obračuna**        | N2 + znak \".\" +     | *     | *  |
|    |                           | N2 + znak \".\" + N4\ | *Da** | *K |
|    |                           | Primjer: 13.03.2006   |       | ** |
+----+---------------------------+-----------------------+-------+----+
| 4. | Šifra pomagala iz Popisa  | A4N2AN1 ili A12 ili   | **Da  | K  |
|    | pomagala                  | A13                   | ^4^** |    |
+----+---------------------------+-----------------------+-------+----+
| 5. | Količina pomagala iz      | N (max 5) + znak      | Da    |    |
|    | Popisa pomagala           | \"**.**\" + N2        |       |    |
+----+---------------------------+-----------------------+-------+----+
| 6. | Ukupni iznos za pomagala  | N (max 9) + znak      | Da    | K  |
|    | (sa sudjelovanjem         | \"**.**\" + N2        | **^   |    |
|    | osiguranika)              |                       | 10^** |    |
+----+---------------------------+-----------------------+-------+----+
| 7  | Šifra proizvođača         | N10                   | Ne    | K  |
| \. |                           |                       | **    |    |
|    |                           |                       | ^5^** |    |
+----+---------------------------+-----------------------+-------+----+
| 8  | Broj potvrde izabranog    | N14                   | **Ne  | K  |
| \. | doktora                   |                       | ^1    |    |
|    |                           | Sastoji se od šifre   | ,3^** |    |
|    |                           | zdr.                  |       |    |
|    |                           | ustanove-ordinacije   |       |    |
|    |                           | privatne prakse       |       |    |
|    |                           | (N9) + rednog broja   |       |    |
|    |                           | unutar godine (N4) +  |       |    |
|    |                           |                       |       |    |
|    |                           | kontrolni broj        |       |    |
|    |                           | izračunat po modelu   |       |    |
|    |                           | 11(N1); Primjer:      |       |    |
|    |                           | 07730773900019        |       |    |
+----+---------------------------+-----------------------+-------+----+
| 9  | Šifra veličine obloge za  | N4                    | Ne    | K  |
| \. | ranu                      |                       | **    |    |
|    |                           |                       | ^6^** |    |
+----+---------------------------+-----------------------+-------+----+
| 10 | Identifikacija izdanog    | ANS(max 30)           | Ne    |    |
| \. | pomagala                  |                       | **    |    |
|    |                           |                       | ^8^** |    |
+----+---------------------------+-----------------------+-------+----+
| 11 | Identifikator ePotvrde (  | ANS(max100)           | Ne    |    |
| \. | broj eOdobrenja )         |                       | **    |    |
|    |                           |                       | ^9^** |    |
+----+---------------------------+-----------------------+-------+----+
| 12 | Iznos razlike u cijeni    | N (max 9) + znak      | Ne    |    |
| \. |                           | \"**.**\" + N2        | **^   |    |
|    |                           |                       | 11^** |    |
+----+---------------------------+-----------------------+-------+----+

1 pri određivanju kontrolne znamenke koristi se standard ISO 7064, MOD
11,10 (za potvrde ovjerene nakon 01.01.2006.)

2 provjerava se ako podatak postoji

3 ako postoji broj ovjerene potvrde, broj potvrde izabranog doktora nije
obavezan podatak. Ako broj ovjerene potvrde ne postoji, broj potvrde
izabranog doktora je obavezan podatak.

> Mora biti upisan barem jedan od podataka za identifikaciju potvrde
> (broj potvrde, broj potvrde izabranog doktora ili e-identifikator
> odobrene potvrde)

4 Od 1.5.2024 na računu se mora slati 13-znamenkasta šifra pomagala koje
je isporučeno ( osim za pomagala koja su odobrena kao **Propisivanje
izvan pravilnika** )

5 primjenom novog pravilnika za ortopedska pomagala -- šifrom pomagala
točno je određen i proizvođač te se u tom slučaju ne mora pisati šifra
proizvođača u slogu izdanih pomagala

6 u slučaju izdavanja obloga za ranu za 12 znamenkaste šifre, u ovo
polje upisuje se četveroznamenkasta šifra veličine obloge ( jer se
cijena pomagala određuje prema veličini obloge ). Vidi Prilog 9

7 Upisuje se troslovna oznaka službene valute u Republici Hrvatskoj

8 Za pomagala koja podliježu povratu, u polje br. 10 upisuje se serijski
broj ili barkod izdanog pomagala

9 U slučajevima izdavanja pomagala preuzetih iz sustava ePomagala --
upisuje se e-identifikator odobrene potvrde

10 U polje 6 upisuje se cijena pomagala s Osnovne liste pomagala ( sa
PDV-om)

11 Upisuje se razlika u cijeni za pomagala s dodatne Liste Pomagala s
PDV-om (doplata koju plaća osiguranik)

## Provjera podataka:

+-------------------+-----------------+--------------------------------+
| ***Polje***       | ***Gdje se      | ***Tko provjerava i što        |
|                   | nalazi***       | provjerava***                  |
+===================+=================+================================+
| **Šifra           | Račun - rbr. 2. | **Isporučitelj** provjerava:   |
| isporučitelja**   |                 |                                |
|                   |                 | \- provjera kontrolne znamenke |
|                   |                 | *(vidi prilog 3)*              |
|                   |                 |                                |
|                   |                 | ***HZZO*** provjerava:         |
|                   |                 |                                |
|                   |                 | \- prema šifarniku HZZO        |
+-------------------+-----------------+--------------------------------+
| **Broj potvrde za | **Račun - rbr.  | ***HZZO*** provjerava:         |
| ortopedsko        | 4.\             |                                |
| pomagalo, I i II  | Stavka pomagala | \- provjera u bazi ovjerenih   |
| dio**             | -- rbr. 2.**    | potvrda HZZO                   |
+-------------------+-----------------+--------------------------------+
| **Datum           | **Račun - rbr.  | ***HZZO*** provjerava:         |
| obračuna**        | 5.\             |                                |
|                   | Stavka pomagala | -   mora biti manji od datuma  |
|                   | -- rbr. 3.\     |     zaprimanja računa u HZZO-u |
|                   | **              |                                |
|                   |                 | -   mora biti veći ili jednaki |
|                   |                 |     datumu narudžbe            |
+-------------------+-----------------+--------------------------------+
| **Vrsta potvrde / | Račun -- rbr.   | **[HZZO]{.smallcaps}**         |
| tiskanice**       | 6.              | provjerava:                    |
|                   |                 |                                |
|                   |                 | [-]{.smallcaps} provjera prema |
|                   |                 | šifarniku HZZO-a *(vidi prilog |
|                   |                 | 4.)*                           |
+-------------------+-----------------+--------------------------------+
| **Datum narudžbe  | Račun - rbr. 7. | ***HZZO*** provjerava:         |
| pomagala**        |                 |                                |
|                   |                 | -   mora biti manji od datuma  |
|                   |                 |     zaprimanja računa u HZZO-u |
|                   |                 |                                |
|                   |                 | -   mora biti manji ili        |
|                   |                 |     jednaki datumu izdavanja   |
|                   |                 |                                |
|                   |                 | -   max 30 dana od datuma      |
|                   |                 |     ovjere potvrde             |
+-------------------+-----------------+--------------------------------+
| **Broj potvrde za | Račun - rbr. 8. | ***HZZO*** provjerava:         |
| ortopedsko        |                 |                                |
| pomagalo, I i II  |                 | \- provjera u bazi ovjerenih   |
| dio, oznaka D**   |                 | potvrda HZZO-a                 |
+-------------------+-----------------+--------------------------------+
| **Broj police     | Račun -- rbr.   | **Isporučitelj *i HZZO***      |
| dopunskog         | 9.              | provjeravaju:                  |
| osiguranja**      |                 |                                |
|                   |                 | \- provjera valjanosti         |
|                   |                 | iskaznice za dopunsko          |
|                   |                 | osiguranje\                    |
|                   |                 | - provjera u bazi dopunsko     |
|                   |                 | osiguranih osoba HZZO-a        |
+-------------------+-----------------+--------------------------------+
| Iznos na teret    | Račun -- rbr.   | ***HZZO*** provjerava:         |
| HZZO-a            | 14.             |                                |
|                   |                 | Iznos na teret HZZO = iznos za |
|                   |                 | pomagala -- sudjelovanje       |
|                   |                 | (osiguranika ili dopunskog) +  |
|                   |                 | ukupan iznos fakturiranih      |
|                   |                 | postupaka                      |
+-------------------+-----------------+--------------------------------+
| **Identifikacija  | Račun - rbr. 16 | ***HZZO*** provjerava:         |
| osigurane osobe   | i 17.           |                                |
| HZZO, II i I      |                 | \- provjera u bazi osiguranih  |
| dio**             |                 | osoba HZZO-a                   |
+-------------------+-----------------+--------------------------------+
| **Matični broj    | Račun - rbr.    | **Isporučitelj *i HZZO ***     |
| osigurane osobe** | 18.             | provjeravaju:                  |
|                   |                 |                                |
|                   |                 | \- provjera kontrolne znamenke |
|                   |                 | *(vidi prilog 5)*\             |
|                   |                 | - provjera u bazi osiguranih   |
|                   |                 | osoba HZZO-a                   |
+-------------------+-----------------+--------------------------------+
| **Broj            | Račun - rbr.    | ***HZZO*** provjerava:         |
| bolesničkog lista | 19.             |                                |
| INO osigurane     |                 | \- provjera u bazi INO         |
| osobe**           |                 | osiguranih osoba HZZO-a        |
+-------------------+-----------------+--------------------------------+
| **Država          | Račun - rbr.    | **Isporučitelj** i ***HZZO***  |
| osigurane osobe** | 20.             | provjeravaju:                  |
|                   |                 |                                |
|                   |                 | \- provjera prema šifarniku    |
|                   |                 | HZZO-a *(vidi prilog 2)*       |
+-------------------+-----------------+--------------------------------+
| **Šifra           | Stavka pomagala | ***HZZO*** provjerava:         |
| pomagala**        | -- rbr. 4.      |                                |
|                   |                 | \- provjera u Popisu pomagala  |
+-------------------+-----------------+--------------------------------+
| **Ukupni iznos za | Stavka pomagala | ***HZZO*** provjerava:         |
| pomagala**        | -- rbr. 6.      |                                |
|                   |                 | \- provjera s ovjerenom        |
|                   |                 | Potvrdom                       |
+-------------------+-----------------+--------------------------------+
| **Šifra           | Stavka pomagala | ***HZZO provjerava:***         |
| proizvođača**     | -- rbr. 7       |                                |
|                   |                 | ***- provjera prema šifarniku  |
|                   |                 | proizvođača***                 |
+-------------------+-----------------+--------------------------------+

##  Prilozi:

### Prilog 1: Međunarodni standard ISO 8859-2

  ----------- ------------------- ------------------- -------------------
  **Znak**    **ISO 8859-2                            **WIN 1250**
              Latin2**                                

              Decimalni kod       Heksadec. kod       Decimalni kod

  **Č**       **200**             **C8**              **200**

  **č**       **232**             **E8**              **232**

  **Ć**       **198**             **C6**              **198**

  **ć**       **230**             **E6**              **230**

  **Š**       **169**             **A9**              **138**

  **š**       **185**             **B9**              **154**

  **Đ**       **208**             **D0**              **208**

  **đ**       **240**             **F0**              **240**

  **Ž**       **174**             **AE**              **142**

  **ž**       **190**             **BE**              **158**
  ----------- ------------------- ------------------- -------------------

### Prilog 2: Države osigurane osobe (Države potpisnice međunarodnog ili posebnog sporazuma o zdravstvenom osiguranju)

<http://www.hzzo-net.hr/partneri/sifrarnici/Drzave.xls>

### Prilog 3: Izračunavanje kontrolne znamenke šifre isporučitelja

Šifra isporučitelja sastoji se od devet znakova (brojeva).

Ako pojedine znakove šifre označimo na način:

  -------- -------- -------- -------- -------- -------- -------- -------- --------
  **A1**   **A2**   **A3**   **A4**   **A5**   **A6**   **A7**   **A8**   **A9**

  -------- -------- -------- -------- -------- -------- -------- -------- --------

> onda se kontrolna znamenka izračunava na sljedeći način:

  ------- ------- ------- ------- ------- ------- ------- ------- -------
  **A1 \* **+ A2  **+ A3  **+ A4  **+ A5  **+ A6  **+ A7  **+ A8  
  9**     \* 8**  \* 7**  \* 6**  \* 5**  \* 4**  \* 3**  \* 2**  

  ------- ------- ------- ------- ------- ------- ------- ------- -------

> Rezultat se [cjelobrojno]{.underline} dijeli sa **11**.
>
> Kontrolna znamenka se izračunava na sljedeći način ovisno o
> [cjelobrojnom ostatku]{.underline} postupka dijeljenja:

1.  ako je cjelobrojni ostatak dijeljenja [veći]{.underline} od **1**,
    > onda se kontrolna znamenka dobiva oduzimanjem cjelobrojnog ostatka
    > od broja **11**.

```{=html}
<!-- -->
```
1.  ako je cjelobrojni ostatak jednak **1**, kontrolna znamenka je
    > **0**.

```{=html}
<!-- -->
```
1.  ako je cjelobrojni ostatak jednak **0**, kontrolna znamenka je
    > **0**.

> [Primjer:]{.underline}
>
> Šifra: **00620062?**
>
> **0**\*9 + **0**\*8 + **6**\*7 + **2**\*6 + **0**\*5 + **0**\*4 +
> **6**\*3 + **2**\*2 = 76
>
> 76/11 = 6, ostatak dijeljenja je ***10***.
>
> 11 - ***10*** = **1** = A9 (kontrolna znamenka)

***Prilog 4: Vrsta pomagala/tiskanice***

U polje *vrsta pomagala/tiskanice* računa moguće vrijednosti upisa su:

> 1 - ortopedska
>
> 2 - slušna
>
> 3 - stomatološka
>
> 4 - očna
>
> 5 - popravak
>
> 7 -- za šećernu bolest
>
> 8 -- obloge za rane

***Prilog 5: Izračunavanje kontrolne znamenke matičnog broja osigurane
osobe***

Matični broj osigurane osobe je fiksni broj koji HZZO dodjeljuje svakoj
osiguranoj osobi.

Sastoji se od devet znakova (brojeva) gdje je deveti znak kontrolna
znamenka koja se izračunava na slijedeći način:

-   Znamenku množimo s nizom konstantnih pondera

    7 6 5 4 3 2 7 6 s lijeva na desno.

-   Zbrajamo dobivene vrijednosti i njihovu sumu djelimo sa 11

-   Računamo razliku između 11 i ostatka dijeljenja

-   Razlika između 11 i ostatka dijeljenja je ***KONTROLNA ZNAMENKA***,
    osim ako je ostatak dijeljenja = 0, tada je ***kontrolna znamenka***
    = 0, ili ako je ostatak dijeljenja =1 tada se uzima slijedeći
    osmeroznamenkasti broj i za njega se računa kontrolna znamenka.

Primjer izračuna kontrolne znamenke za broj 10000011

  -------------------------- ------------------------ ------- ------- ------- ------- ------- ------- ------- ----------
  Znamenke u serijskom broju **1**                    **0**   **0**   **0**   **0**   **0**   **1**   **1**   **k.z**.
  (bez kontrolne)                                                                                             

  Ponderi                    **7**                    **6**   **5**   **4**   **3**   **2**   **7**   **6**   

  Umnošci                    **7**                    **0**   **0**   **0**   **0**   **0**   **7**   **6**   

  Zbrojevi umnožaka          **7+0+0+0+0+0+7+6=20**                                                           

  Dijeljenje po modulu 11    **20 / 11 = 1 i ostatak                                                          
                             9**                                                                              

  Razlika između 11 i        **11 -- 9 = 2**                                                                  
  ostatka                                                                                                     

  Kontrolna znamenka je \... **2**                                                                            
  -------------------------- ------------------------ ------- ------- ------- ------- ------- ------- ------- ----------

Znači konačni matični broj osigurane osobe je 10000011**2**

### 

### Prilog 7: Primjeri ispravnog vodećeg sloga računa i stavki računa (pomagala)

Kako bi primjer bio jasniji i pregledniji, korišteni su sljedeći načini
označavanja:

1.  podaci koji su obvezni, napisani su **podebljano**

2.  podaci koji su obvezni uz određene uvjete, napisani su *ukošeno*

3.  na mjestima gdje nema podataka ili se pojavljuju razmaci, upisan je
    znak \"◊\"

## 

## Način izračunavanja cijene pomagala:

## Od 01.01.2013 uveden je PDV na sva pomagala. 

## Na Internet stranicama HZZO-a, u Popisu pomagala objavljene su cijene pomagala bez PDV-a, stopa i cijena s PDV-om. Zbog jednoobraznog obračuna cijene pomagala definiramo :

## Ukupna cijena izdanog pomagala računa se na način da se uzima cijena sa PDV-om iz Popisa pomagala i množi sa količinom izdanog pomagala.

Npr:

 **[032112080301]{.underline}**   **Igle za injektor za terapiju
šećerne bolesti**                  

Jed.cij.bez PDV **[    0.99]{.underline}**                       

Stopa PDV-a    **[   5.00%]{.underline}** 

Jed.cij.sa PDV **[    1.04]{.underline}**

Izdano 150 igala

Ukupna cijena= Cijena sa PDV-om \* količina = 1,04 \* 150 = 156,00

od 1.1.2023 mijenja se način izračuna cijena pomagala ( računi izdani u
2023 obračunavaju se u EUR-ima )

U Popisu pomagala objavljuje se jedinična cijena pomagala na četiri
decimale bez PDV-a i stopa PDV-a za pojedino pomagalo.

Cijena pomagala računa se na način:

Jedinična cijena pomagala bez PDV-a (na četiri decimale) \* količina
rezultat se zaokruži se na dvije decimale, na taj iznos se zaračuna PDV,
i konačan iznos zaokruži na dvije decimale.

Primjer izračuna cijena pomagala za račune izdane od 1.1.2023 ( pomagalo
s mjernom jedinicom cm2)

0209031121016 Poliuretan/Pjena sa dodatkom srebra ili aktivnog ugljena,
iznad 75 cm2 ,ConvaTec ,Aquacel Ag Foam Non-Adhesive Dressing 20x20cm

Jedinična cijena bez PDV-a 0.0531 EUR

Stopa 5.00%

Mjerna jedinica 1 cm2 kvadratni centimetar

Izdano 10 pomagala

Cijena bez PDV-a = 0,0531 \* 20\*20\*10 = 212,40
(jed.cij.bezPDV-a\*dim1\*dim2\*količina; zaokruženo na 2dec)

Cijena sa PDV-om = 212,40+212,40\*5/100 = 223,02 EUR

Za račune izdane nakon 1.1.2023, za koje je datum izdavanja pomagala u
2022 (ili ranije) radi se konverzija jedinične cijene bez PDV-a (koja je
vrijedila na dan izdavanja pomagala) u EUR-e (
jedinična_cijena_bez_PDVa/7,53450 na 4 decimale ) i računa na ranije
propisan način

***Primjer Slog računa:***

60:200326791:Ustanova
1::02.01.2023:7:02.01.2023:25/2023-D:10042090:17.77:0.00:6.62:0.32:11.15:0.53:::123456789::::0.00:0.00:25/2023:10055:11201::7773017bf16f2155b-xebe68d184545c21027cf1:02.01.2023:0.00::EUR:

***Stavke \"Pomagala\":***

61::02.01.2023:0324120807006:50.00:15.12:10250::::7773017bf16f2155b-xebe68d184545c

21027cf1:0.00:

61::02.01.2023:0321120808003:50.00:2.65:10250::::7773017bf16f2155b-xebe68d184545c2

1027cf1:0.00:

\~

### 

### Prilog 8: Izračunavanje kontrolne znamenke broja Potvrde ortopedskog pomagala 

Dužina podatka: 13 (fiksna dulžina, numerički podatak)

Kontrolna znamenka: 14. mjesto ===\> kontrola po modulu 11

**POSTUPAK IZRAČUNA KONTROLNE ZNAMENKE PO MODULU 11**

-   Znamenku množimo s nizom konstantnih pondera

    7 6 5 4 3 2 7 6 5 4 3 2 7 s LIJEVA NA DESNO.

-   Zbrajamo dobivene vrijednosti, i njihovu sumu djelimo sa 11

-   Računamo razliku između 11 i ostatka dijeljenja

-   Razlika između 11 i cjelobrojnog ostatka dijeljenja je ***KONTROLNA
    ZNAMENKA***

-   ako je cjelobrojni ostatak dijeljenja = 0, tada je kontrolna
    > znamenka = 5

-   ako je cjelobrojni ostatak dijeljenja = 1, tada je kontrolna
    > znamenka = 0

**Primjer**

izračun kontrolne znamenke za broj 0773077390001

  ----------------- ----------------------------------- ---- ---- ---- --- ---- ---- ---- ---- --- --- --- --- ---
  Znamenke u broju  0                                   7    7    3    0   7    7    3    9    0   0   0   1   K
  potvrde (bez                                                                                                 
  kontrolne)                                                                                                   

  Ponderi           7                                   6    5    4    3   2    7    6    5    4   3   2   7    

  Umnošci           0                                   42   35   12   0   14   49   18   45   0   0   0   7    

  Zbrojevi umnožaka 0+42+35+12+0+14+49+18+45+0+0+0.+7 =                                                         
                    222                                                                                        

  Dijeljenje po     222/11 = 2 i ostatak 2                                                                      
  modulu 11                                                                                                    

  Razlika između 11 11 - 2 = 9                                                                                  
  i ostatka                                                                                                    

  Kontrolna         9                                                                                           
  znamenka je \...                                                                                             
  ----------------- ----------------------------------- ---- ---- ---- --- ---- ---- ---- ---- --- --- --- --- ---

### Prilog 9: Šifarnik veličina obloga za rane 

Koristi se za pomagala sa 12-znamenkastom šifrom.Za pokrivala za rane uz
količinu izdanog pomagala propisuje se i veličina obloge. Cijena takvog
pomagala izračunava se na način

Cijena pomagala = količina pomagala \* veličina pomagala \* jedinična
cijena

Veličine pojedine obloge definirane su šifarnikom na web stranici

<http://www.hzzo-net.hr/dload/partneri/sifrarnici/Obloge_za_rane_26102019.xls>

***Prilog 10: Šifarnik zdravstvenih ustanova***

Popis zdravstvenih ustanova, u kojem je naveden nadležni RU/PS (vezano
za određivanje naziva datoteke) nalazi se na web stranici HZZO-a:

<http://www.hzzo.hr/hzzo-za-partnere/sifrarnici-hzzo-a/>

***Prilog 11: Zdravstvena zaštita neosiguranih osoba-stranaca prema
sporazumu o obradi računa s MIZ-om***

Za izbjeglice iz Ukrajine od 01.01.2023. godine umjesto aktivnosti 00001
koristi se konto 3712109 (upisuje se u polje 25 vodećeg sloga računa)
