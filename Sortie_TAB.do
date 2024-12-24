ssc install asdoc
ssc install tabout

	* Répartition (%) de la population en age de travailler par groupe d'âge selon le milieu de résidence et le sexe.

 	table (c_age) (m4e milieu_etendu) if c_age_trav [pw=weightemploi], row col
	*bysort A10 : tab age_quin_eco B06 if B36<=3&B08>=15 [iw=POIDS_STRATE_P], col nofreq
	
	*Taux d'activité selon la région, le milieu de résidence et le sexe 	
	table (reg) (mil sex) if B08>=15 [pw=POIDS_STRATE_P], nformat(%5.2f) stat(mean actif)
		
	asdoc table c_age (m4e milieu_etendu) if c_age_trav [pw=weightemploi], save(C:\Users\Pro\Desktop\TPAS2\TP_AS2_2024\diroutput\Emp1.rtf) row col title(Population en âge de travailler par....) append
	
	**** Structure de la population en âge de travailler (15 ans ou plus) 
	asdoc table c_age (m4e milieu_etendu) if c_age_trav [pw=weightemploi], save(C:\Users\Pro\Desktop\TPAS2\TP_AS2_2024\diroutput\Emp1.rtf) row col fhc(\b) fhr(\b) title(Tableau 5.2) append
	
	
	*Répartition de la population habituellement active par région, selon le milieu de résidence et le sexe en xxxx
	
	table (cod_reg) (strate B06) if B36<=3 [pw=POIDS_STRATE], nformat(%5.0f)

	*Proportion de la population en âge de travailler  (15-60) active et de la population occupée par sexe selon le milieu de résidence

	table (strate B06) if pop_age_trav [pw=POIDS_STRATE], nformat(%5.2f) stat(mean pop_occup  mean actif)

		*Répartition (%) des actifs occupés par sexe et milieu de résidence selon le statut de fréquentation scolaire.
	
	tabout B29 using "$diroutput\tests.xls", over(strate B06) replace

		*Tableau 5.14 : Taux d'occupation selon la région et le sexe 
	table cod_reg (B06) if B08<=60&B08>=15 [pw=POIDS_STRATE], nformat(%5.2f) stat(mean pop_occup)

	
	***** TAUX de NEET  *****