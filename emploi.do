
	**** Définir le point comme séparateur de milliers
	set dp comma
	**** Demander à stata d'afficher les résultats complets (long tableau)
	set more off

*****Précarité de l'emploi******

**Chargement de la base
use "C:\STATA\Projet_STATA\emploi.dta", clear

**Vérification des indicateurs**
replace m4 = 0 if m4==.
svyset [pweight=hhweight]

**Age des individus et Personne en age de travailler**

gen age_group = cond(m4 >= 70,7,cond(m4 >= 60 & m4 < 70,6,cond(m4 >= 50 & m4 < 60,5,cond(m4 >= 40 & m4 < 50,4,cond(m4 >= 30 & m4 < 40,3,cond(m4 >= 20 & m4 < 30,2,cond(m4 >= 10 & m4 < 20,1,0)))))))

label define age_labels 0 "missing" 1 "10-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" 6 "60-69" 7 "70+",replace
label values age_group age_labels
tab age_group
gen c_age = cond(m4>=65,4,cond(m4>=35,3,cond(m4>=15,2,cond(m4<15 & m4>0,1,0))))
label define c_age 0"missing" 1"0_14ans" 2"15_34ans" 3"35_64ans" 4"65_Plus",replace
label value c_age c_age
label var c_age "tranche_age"
svy: tab c_age

gen c_age_trav = cond(m4>=15 & m4<=65,2,cond(m4==0,0,1))
label var c_age_trav "Population_age_travailler"
label define c_age_trav 0"missing" 1"age_non_emp" 2"age_emp",replace
label value c_age_trav c_age_trav
svy: tab c_age_trav

****Personne en emploi****

gen Emp=cond(SE2==1&m4!=0,1,0)
	
	**** Reconstitution de SE3
	gen SE3b=0
	foreach point of varlist SE3_1-SE3_9 {
	gen `point'_b=cond(`point'==2,0,1)
	replace SE3b=(SE3b + `point'_b)&m4!=0
	}
	drop SE3_*_b
	gen recup=cond(SE4==1&(SE5<=4) | SE4==1&(SE5==6)&SE6B==1 | SE3b!=0&Emp==0 | SE4==1&(SE6A==1), 1, 0)
	replace Emp=cond(recup==1 | Emp==1,1,cond(m4==0,2,0))
	
	label define Emp 2"missing" 1"Emploi" 0"Non Emploi",replace
	label value Emp Emp
	label var Emp "Personne_emploi"
svyset [pweight=weightemploy]
svy: tab Emp

*******Personne en emploi précaire******
	gen statut_emploi = cond(AP9A == 3 | AP12 != 1 &  AP10A<12 & AP10B<5 & AP10C<40 & AP11A==4 | AP15C == 2,3,cond(m4==0,1,cond(Emp==0&m4!=0,2,0)))
label define statut_emploi 3"Précaire" 2"Non_emp" 1"missing" 0"Non_précaire",replace
label value statut_emploi statut_emploi
label variable statut_emploi "Statut d'Emploi"
tab statut_emploi
tab statut_emploi if statut_emploi!=1 & statut_emploi!=2
svy: tab m3E statut_emploi if statut_emploi!=1 & statut_emploi!=2
graph bar (count) Emp if Emp==1 [pweight=weightemploy], over(m3E) over(statut_emploi) ///
    bar(1, color(blue)) title("Répartition de la population par type d'emploi et par sexe") ///
	ytitle("Effectif des individus") ///
    blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10)
***Les employés en fonction des catégoties socio-proffesionnelle***

gen statut = .
replace statut = 0 if inlist(AP3, 1, 2, 3, 4, 5, 6)  // Salariés
replace statut = 1 if inlist(AP3, 7, 8, 9, 10)      // Non salariés

label define statut_label 1 "Non salarié" 0 "Salarié",replace
label values statut statut_label

*****ANALYSE DES DONNEES*****

****Analyse des individus*****
svyset [pweight=hhweight]
tab age_group m3E
svy: tab age_group m3E
tab strate
svy: tab m3E
tab Region
tab AP1_NOM_0
tab Emp
tab statut
graph pie Region [pweight=hhweight], over(m3E) ///
plabel(_all percent, size(medium) color(white) angle(90) position(inside) format(%9.1f) lcolor(black) lwidth(medium)) ///
title("Répartition des personnes par sexe")

****Les individus en emplois par sexe, par tranche d'age et par categories socio-proffesionnelle***

graph bar (count) Emp if Emp==1 [pweight=weightemploy], over(statut_emploi) ///
    bar(1, color(blue)) title("Répartition des personnes en emploi par age") ///
	ytitle("Effectif des individus") ///
    blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10)

tab m3E if Emp==1
graph pie Emp if Emp==1 [pweight=weightemploy], over(m3E) ///
plabel(_all percent, size(medium) color(white) angle(90) position(inside) format(%9.1f) lcolor(black) lwidth(medium)) ///
title("Répartition des personnes en emploi par sexe")
	
graph bar (count) Emp if Emp==1 [pweight=weightemploy], over(c_age) ///
    bar(1, color(blue)) title("Répartition des personnes en emploi par age") ///
	ytitle("Effectif des individus") ///
    blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10)
	
graph bar (count) Emp if Emp==1  [pweight=weightemploy], over(AP3) ///
    bar(1, color(green)) title("Répartition des personnes en emploi par pofil économique ") ///
	ytitle("Effectif des individus") ///
    blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10)
	
graph pie Emp if Emp==1  [pweight=weightemploy], over(statut) ///
plabel(_all percent, size(medium) color(white) angle(90) position(inside) format(%9.0f) lcolor(black) lwidth(medium)) ///
title("Répartition des personnes en emploi par profil économique")

graph pie Emp if Emp==1  [pweight=weightemploy], over(statut_emploi) ///
plabel(_all percent, size(small) color(white) angle(90) position(inside) format(%9.1f) lcolor(black) lwidth(medium)) ///
title("Répartition des personnes par type d'emploi")

tab strate Emp if Emp==1
svy: tab strate Emp if Emp==1
**Les individus en emploi précaire***
**Par sexe
tab m3E  statut_emploi
svy: tab strate statut_emploi if statut_emploi==3
svy: tab AP6A statut_emploi if statut_emploi==3
svy: tab c_age statut_emploi if statut_emploi==3

graph pie statut_emploi if statut_emploi==3 [pweight=weightemploy], over(m3E) ///
plabel(_all percent, size(medium) color(white) angle(90) position(inside) format(%9.1f) lcolor(black) lwidth(medium)) ///
title("Répartition des personnes en emploi précaire par sexe")
**Par tranche d'age
tab c_age statut_emploi
graph bar (count) statut_emploi if statut_emploi==3 [pweight=weightemploy], over(c_age) ///
    bar(1, color(blue)) title("Répartition des personnes en emploi par age") ///
	ytitle("Effectif des individus") ///
    blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10)

**Par secteur d'activités
tab AP3 statut_emploi
graph bar (count) statut_emploi if statut_emploi==3 [pweight=weightemploy], over(AP3) ///
    bar(1, color(orange)) title("Répartition par des personnes en emploi par catégories socio-professionnelles") ///
    ytitle("Nombre de personnes") ///
    blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10) ///
    legend(off)
	
graph pie statut_emploi if statut_emploi==3 [pweight=weightemploy], over(statut) ///
plabel(_all percent, size(medium) color(white) angle(90) position(inside) format(%9.1f) lcolor(black) lwidth(medium)) ///
title("Répartition des personnes en emploi précaire par profil économique")

graph bar (count) statut_emploi if statut_emploi==3 [pweight=weightemploy], over(AP1_NOM_0) ///
bar(1, color(orange)) title("Répartition des personnes en emploi précaire par metier") ///
blabel(bar, size(small) color(black) angle(90) position(outside) format(%9.0f) lcolor(black) lwidth(medium)) ///
    ysize(6) xsize(10) ///
    legend(off)

****Part des travailleur pour compte propre et des travailleurs familiaux dans le total des emplois

gen TEV = .
// Condition initiale
replace TEV = 0 if Emp == 1
// Condition pour TEV = 1
replace TEV = 1 if Emp == 1 & (AP3 == 8 | AP3 == 9)
svy: tab TEV
tab TEV

gen TEV_prec = .
// Condition initiale
replace TEV_prec = 0 if statut_emploi==3
// Condition pour TEV = 1
replace TEV_prec = 1 if statut_emploi==3 & (AP3 == 8 | AP3 == 9)
svy: tab TEV_prec
****Taux de pluriactivités****
gen TPA = .
// Condition initiale
replace TPA = 0 if Emp == 1
// Condition pour TPA = 1
replace TPA = 1 if Emp == 1 & (AS1A == 1 | AS1C == 1)
svy: tab TPA

gen TPA_prec = .
// Condition initiale
replace TPA_prec = 0 if statut_emploi == 3
// Condition pour TPA = 1
replace TPA_prec = 1 if statut_emploi == 3 & (AS1A == 1 | AS1C == 1)
svy: tab TPA_prec


****Taux d'emploi informel***
gen TINF = .
replace TINF = 0 if Emp==1
replace TINF = 1 if AP16_21A==2 | AP16_22A==2 | AP16_23A==2

svy: tab TINF

****Taux de salarisation****
gen PESAL = .
replace PESAL = 0 if Emp==1
replace PESAL = 1 if AP3 >=1 & AP3<=6 

svy: tab PESAL

****Taux de salarisation d'emploi précaire****
gen PESAL_prec = .
replace PESAL_prec = 0 if statut_emploi==3
replace PESAL_prec = 1 if AP3 >=1 & AP3<=6

svy: tab PESAL_prec

****Ratio emploi/population****
gen RPOP = .
// Condition initiale
replace RPOP = 0 if c_age_trav == 1
// Condition pour REPOP = 100
replace RPOP = 1 if Emp == 1
label define RPOP 1"Personne_emploi" 0"Personne_age_emploi",replace
	label value RPOP RPOP
	label var RPOP "Ratio emploi/population"
tab RPOP

