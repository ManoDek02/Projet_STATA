*****  Préparation de l'environnement de travail 
	ssc install asdoc    //nécessite la connexion
	ssc install tabout   // nécessite la connexion
	notes : Cette base de données est issue de l'enquête ERI-ESI 
	**** Vider la mémoire 
	capture clear 

	**** Définir le point comme séparateur de milliers
	set dp comma
	**** Demander à stata d'afficher les résultats complets (long tableau)
	set more off

	***** Définir et fixer les répertoires de travail 
	*** Créer un repertoire de travail et trois sous répertoires (TP_AS2_2024; dirdata; dirdo; diroutput)
	**** Adapter le répertoire d'accès : 
	***C:\Users\ba266\Documents\Projet_Stat_du_Travail_2024-2025
global rep_trv ="C:\Users\ba266\Documents\Projet_Stat_du_Travail_2024-2025"
capture mkdir "$rep_trv\dirdata" 
capture mkdir "$rep_trv\dirdo"
capture mkdir "$rep_trv\diroutput"
*** fixation des repértoires 
	global rdata="$rep_trv\dirdata"
	global rdo="$rep_trv\dirdo"
	global routput="$rep_trv\diroutput"

capture log close 
log using "$routput\TP_AS2_2024.smcl", replace 
	
	*cd "$rdo"
*========================================================================
		//On extrait les gens qui les chef des unitées de production industrielle 
use using "$rdata\upi_SN.dta", replace
keep if (F1B == 1 | F1B == 2) & (F2A == 2) & (F3 == 1 | F3 == 3) & (F4 == 1 | F4 == 2)
count
scalar nombre_entreprise_informel = r(N)
display(nombre_entreprise_informel)
**====================================================================
		// Calcul de quelque indicateur du secteur informel
************** Effectifs moyenne des UPI ***********************************
*** Capter l'effectif moyen des UPI au démarrage des activités
preserve
collapse (mean) CUP5E [pweight=PondSI],by(CUP1B)
cd "C:\Users\Abdou\Documents\GitHub\Projet_STATA"
export excel using "base.xlsx", firstrow(variables) replace
restore
*** Capter le pourcentage d'UPI ayant de l'électricité 
svyset [pweight=PondSI] //fixer les ponderations pour le reste de l'analyse
svy: tab CUP2D1_B CUP1B , cell
*** capter le pourcentage d'UPI ayant accès à un système d'évacuation des déchets 
svy: tabulate CUP2D1_D2 CUP1B, cell
*** Pourcentage d'UPI travaillant à domicile
svy: tab CUP2A CUP1B  ,  cell
****Capter le pourcentage d'UPI dirigées par des femmes
svy: tab m3E CUP1B  

svy: tab  CUP1B cup1aa 
************La main d'oeuvre des UPI *****************
**# Bookmark #6
preserve
collapse (sum) MO1A_TOT (sum) MO1A_SAL (sum) MO1A_NSAL [pweight=PondSI] ,by(CUP1B)
display "le nombre de personne qui tavaille dans l'informel sont de :" MO1A_TOT " dont" MO1A_SAL " sont remunere et " MO1A_NSAL " non remunerer"
export excel using "basemain.xlsx", firstrow(variables) replace
restore

* Créer une variable catégorisée à partir de m4E (âge)
**Methode1
egen age_group1 = cut(m4E), at(0,25,35,45,55,65,100) label
**Methode2
gen age_group = .
replace age_group = 1 if m4E < 25
replace age_group = 2 if m4E >= 25 & m4E <= 34
replace age_group = 3 if m4E >= 35 & m4E <= 44
replace age_group = 4 if m4E >= 45 & m4E <= 54
replace age_group = 5 if m4E >= 55 & m4E <= 64
replace age_group = 6 if m4E >= 65
**Labeliser la variable age 
label define age_label 1 "Moins de 25 ans" 2 "25-34 ans" 3 "35-44 ans" 4 "45-54 ans" 5 "55-64 ans" 6 ">= 65 ans"
label values age_group age_label
**Capter la valeur ajouter par le secteur informel dans l'economie 
preserve
keep if (F1B == 1 | F1B == 2) & (F2A == 2) & (F3 == 1 | F3 == 3) & (F4 == 1 | F4 == 2)
count if missing( DC6A_MAX )
collapse (sum) DC6B_MOY DC6A_MAX DC6C_MIN [pweight=PondSI],by(age_group CUP1B ) 
cd "C:\Users\Abdou\Documents\GitHub\Projet_STATA"
export excel using "base2.xlsx", firstrow(variables) replace
restore
*H.	Le secteur informel et son intégration/réintégration dans les circuits officiels
**Le secteur informel et son intégration/réintégration dans les circuits officiels
svy: tab G30 CUP1B ,  cell
**L'UPI est-elle prête à payer l'impôt sur ses activités 
svy: tab G35 CUP1B ,  cell
**Payement des impots
preserve
collapse (mean) G32C [pweight=PondSI],by(G32B)
restore
*** Faire les analyses temporelle
*====== Regroupement des années 
gen year_group = .
replace year_group = 1 if CUP5B < 1990
replace year_group = 2 if inrange(CUP5B, 1990, 1995)
replace year_group = 3 if inrange(CUP5B, 1996, 2000)
replace year_group = 4 if inrange(CUP5B, 2001, 2005)
replace year_group = 5 if inrange(CUP5B, 2006, 2010)
replace year_group = 6 if inrange(CUP5B, 2011, 2015)
replace year_group = 7 if inrange(CUP5B, 2016, 2017)
replace year_group = 8 if CUP5B == 8888
label define year_label 1 "Avant 1990" 2 "1990-1995" 3 "1995-2000" 4 "2000-2005" 5 "2005-2010" 6 "2010-2015" 7 "2015-2017" 8 " NSP"
label values year_group year_label

**Repartition des UPI en fonction du genre et de la localité
svy: tab year_group CUP1B , cell
**** l'evolution des effectif des UPI en fonction du temps
graph bar (count) [pweight=PondSI], over(year_group) title("Distribution des unités par intervalle d'années")
// Profil par groupe d'âges du chef des UPI « créées » dans le temps
tabulate year_group age_group , chi2
******Analyse de la serie temporelle des UPI 
drop if CUP5B== 8888 
*gen year = CUP5B
preserve
collapse (count) year

graph bar year, over(year, sort(ascending)) bar(1, color(blue)) ///
    title("Nombre d'entreprises créées par année") ///
    xlabel(, angle(45))

restore





