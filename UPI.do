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
preserve
collapse (mean) CUP5E ,by(CUP1B)
restore

tab CUP2D1_B CUP1B if CUP2D1_B == 1 ,  cell

tab CUP2A CUP1B if CUP2A == 6 ,  cell

tab m3E CUP1B if m3E == 2 , cell

tab  CUP1B cup1aa , row
************La main d'oeuvre des UPI *****************
preserve
collapse (sum) MO1A_TOT (sum) MO1A_SAL (sum) MO1A_NSAL 
display "le nombre de personne qui tavaille dans l'informel sont de :" MO1A_TOT " dont" MO1A_SAL " sont remunere et " MO1A_NSAL " non remunerer"
restore


