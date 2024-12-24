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
	**** Adapter le répertoire d'accès : "D:\SAUV_MACHINE_ANSD_DONNEES\Cours_ENSAE_Marché du travail\AS2_2024_Statistique_travail"
capture	mkdir "D:\SAUV_MACHINE_ANSD_DONNEES\Cours_ENSAE_Marché du travail\AS2_2024_Statistique_travail\TP_AS2_2024"
	global reptrav="D:\SAUV_MACHINE_ANSD_DONNEES\Cours_ENSAE_Marché du travail\AS2_2024_Statistique_travail\TP_AS2_2024"
	
	capture mkdir "$reptrav\dirdata"
	capture mkdir "$reptrav\dirdo"
	capture mkdir "$reptrav\diroutput"

	*** fixation des repértoires 
	global rdata="$reptrav\dirdata"
	global rdo="$reptrav\dirdo"
	global routput="$reptrav\diroutput"
	
	capture log close 
	log using "$routput\TP_AS2_2024.smcl", replace 
	
	*cd "$rdo"

	use using "$rdata\emploi.dta", replace
	*** Contrôle Age
	desc 
	codebook m4
	
	*** Activités non rémunérées
	gen SE1=0
	foreach point of varlist SE1_* {
	gen `point'_b=cond(`point'>0,1,0)
	replace SE1=SE1+`point'_b
	}
	tab1 SE1_*_b
  tab SE1
	drop SE1_*_b
	
	label var SE1 "nombre d'activités non rémunérées"
	
	********* Le travail rémunéré (Emploi)
	
	gen c_age_trav=cond(m4>=15,1,0)
	replace c_age_trav=cond(m4>=65&c_age_trav==1,0,c_age_trav)
	
	gen c_age =inrange(m4,15,64)
	replace c_age=cond(m4>=35&m4<=64,2,c_age)
	replace c_age=cond(m4>=65,3,c_age)

	label def c_age 0"0_14ans" 1"15_34ans" 2"35_64ans" 3"65_Plus",replace
	label value c_age c_age
	label var c_age_trav "Population_age_travailler"
	label var c_age "Tranche_age"
	
	******* Identification des personnes en emploi
	**** Employé, indépendant, employeur, App & Stag rémunérés, Aides familiaux 
	***************************************************
	gen Emp=cond(SE2==1,1,0)
	
	**** Reconstitution de SE3
	gen SE3b=0
	foreach point of varlist SE3_1-SE3_9 {
	gen `point'_b=cond(`point'==2,0,1)
	replace SE3b=SE3b + `point'_b
	}
	
	drop SE3_*_b
	keep if c_age!=0
*	save "$dirdata\eri_esi_Emploi_15PLus.dta", replace
	
	*** Récupérer ceux qui ont effectué certaines activités et qui en réalité pensent ne pas avoir travaillé pour une rémunération
	replace Emp=cond(SE3b!=0&Emp==0, 1,Emp)
	**** Recupérer ceux qui ont un emploi rémunéré et qui ne l'ont pas exercé au cours des 7 derniers pour des raisons temporaires
	*replace Emp= cond(Emp==0&SE4==1&SE5<=4, 1, Emp)
	gen recup=cond(SE4==1&(SE5<=4), 1, 0)
	replace recup=cond(SE4==1&(SE5==5|SE5==7|SE5==9)&SE6a==1, 1, recup)
	replace recup=cond(SE4==1&(SE5==6)&SE6b==1, 1, recup)
	
	replace Emp=cond(Emp==0&recup,1,Emp)
	
	*****
		***** Identification des chômeur ******
	gen chom=cond(SE7==1,1,0)
	replace chom=cond(chom==1&SE9<=2,1,0)
	*** Elargissment chômeur
	gen rec_chom=cond(SE7==2&SE8<=9&SE9<=2,1,0)
	replace chom=cond(chom==0&rec_chom==1, 1, chom)
		
	gen Sit_occ=cond(Emp==1,1,0)
	replace Sit_occ=cond(chom==1,4,Sit_occ)
	replace Sit_occ=cond(Sit_occ==0,5,Sit_occ)
	
	**** Intégration de la situation d'occupation
	replace Sit_occ=cond(Sit_occ==1&AP3>=7&AP3<=8,2,Sit_occ)
	replace Sit_occ=cond(Sit_occ==1&AP3==9,3,Sit_occ)
	
	label def sit 1"Employé" 2"Employeur/Ind" 3"Aide_fam/benev" 4"Chom" 5"Hors_MO"
	label val Sit_occ sit
	tab Sit_occ, gen(sit_occ)

	*****  	*** Creation variable secteur informel 
	
	gen sect_inf =cond(Sit_occ==2&AP6e<=2, 1, 0)
	** Il ne peut pas y avoir d'unité informelle pour pour les APU et les Entreprises Publiques ainsi que les ONG 
	replace sect_inf=cond(sect_inf&AP4<=2,0,sect_inf)	
	replace sect_inf=cond(sect_inf&AP4==5,0,sect_inf)
	replace sect_inf=cond(sect_inf&AP6d==2,0,sect_inf)
	*replace sect_inf=cond(sect_inf&AP6d==2,0,sect_inf)
	
	**** Création_variable enregistrement 
	gen enr1=cond(AP6ba==1&AP6ca==1,1,0)
	gen enr2=cond(AP6bb==1&AP6cb==1,1,0)
	gen enr3=cond(AP6bc==1&AP6cc==1,1,0)
	
	gen enr=cond(enr1|enr2|enr3,1,0)

	*** Enregistrement non prouvé
	gen enr1_np=cond(AP6ba==1&AP6ca==2,1,0)
	gen enr2_np=cond(AP6bb==1&AP6cb==2,1,0)
	gen enr3_np=cond(AP6bc==1&AP6cc==2,1,0)
	
	gen enr_np=enr1_np+enr2_np+enr3_np
	
	***
	gen enr_np=cond(enr==0&(enr1_np==1|enr2_np==1|enr3_np==1), 1,0)
	
	replace sect_inf=cond(sect_inf&enr==1,0,sect_inf)
	replace sect_inf=cond(sect_inf&enr_np&AP6a!=3,0,sect_inf)
	replace sect_inf=cond(sect_inf&enr_np&AP6a==3&AP7>=10&AP7!=89,0,sect_inf)
	replace sect_inf=cond(sect_inf&enr_np&AP6a==3&AP7>=10&AP7!=89&AP5>3&AP5!=.,0,sect_inf)

	replace sect_inf=cond(sect_inf&enr_np&AP6a==3&AP7>=10&AP7!=89&AP5<=3,1,sect_inf)

	replace sect_inf =1 if enr_np&AP6a==3&AP7>=10&AP7!=89&AP5<=3	 
	
	********************************
	** Sortie des données *****
	********************************
	/*********
		* Répartition (%) de la population en âge de travailler par groupe d'âge selon le milieu de résidence et le sexe.

 	table (age_quin_eco) (A10 B06) if B36<=3&B08>=15 [pw=POIDS_STRATE_P], nformat(%5.0f)
	bysort A10 : tab age_quin_eco B06 if B36<=3&B08>=15 [iw=POIDS_STRATE_P], col nofreq
	
	*Taux d'activité selon la région, le milieu de résidence et le sexe 	
	table (reg) (mil sex) if B08>=15 [pw=POIDS_STRATE_P], nformat(%5.2f) stat(mean actif)

	
		
	asdoc table Z (X Y) [pw=....], save(......\Tab_Car_Eco\rgph5_Car_econ_b.rtf) row col fhc(\b) fhr(\b) title(Titre) append
	
	**** Structure de la population en âge de travailler (15 ans ou plus) 
	asdoc table (z) (x y) [pw=...], save(.....\NOMFICH.rtf) row col fhc(\b) fhr(\b) title(Tableau 5.2) append
	
	
	*Répartition de la population habituellement active par région, selon le milieu de résidence et le sexe en xxxx
	
	table (cod_reg) (strate B06) if B36<=3 [pw=POIDS_STRATE], nformat(%5.0f)

	*Proportion de la population en âge de travailler  (15-60) active et de la population occupée par sexe selon le milieu de résidence

	table (strate B06) if pop_age_trav [pw=POIDS_STRATE], nformat(%5.2f) stat(mean pop_occup  mean actif)

		*Répartition (%) des actifs occupés par sexe et milieu de résidence selon le statut de fréquentation scolaire.
	
	tabout B29 using "$diroutput\tests.xls", over(strate B06) replace

		*Tableau 5.14 : Taux d'occupation selon la région et le sexe 
	table cod_reg (B06) if B08<=60&B08>=15 [pw=POIDS_STRATE], nformat(%5.2f) stat(mean pop_occup)

	
	
	log close
	
	
	

