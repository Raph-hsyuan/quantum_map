# Quantum Map

- HUANG Shenyuan, WANG Wei

## Introduction 

Quantum Map est une application mobile (Android/IOS), ce qui nous propose deux modes de localisation - mode intérieur et mode extérieur. De plus, C'est une application qui nous propose une grosse possibilité de l'utiliser vraiment partout. Dans le mode extérieur, les utilisatuers peuvent visualiser une carte régulière. Quand les utilisatuers rentrent dans un bâtiment, l'application va proposer de passer automatiquement au mode intérieur. Dans le mode intérieur, l'application nous permet de visualiser une carte présise qui est associée à l'étage dans le bâtiment. Dans cette application, plusieurs capteurs/équipements sont utilisés pour nous permettre de recueillir les données et fournir une expérience utilisateur conviviale.
 
## Scénarios 

Utilisateur: Alice est professeur de françai, elle aime faire du shopping en weenkend. Mais elle n'a aucun sens de l'orientation et donc elle ne sait pas les locations de magasin. 

1. Ce weekend, Alice va aller faire du shopping dans un grand centre commercial. Elle ouvri l'application et elle voit une carte régulière dans la quelle sa location est marquée en temp reél. Lorsqu'elle rentre dans le centre commercial, l'application lui demande si elle souhaite passer au mode intérieur. Alice l'accepte, et donc l'application lui montre une carte intérieure du centre commercial et elle peut voir tous les magasins dans cet étage.
De plus, sa location à l'intérieur est marquée dans la carte. 

2. Dans le centre commercial, Alice veut acheter un portable dans un magasin, mais elle ne sait pas la location. Donc elle fait une recherche "portable" dans l'aaplication, et l'application lui propose plusieurs choix. Elle choisi "HUAWEI", et l'application lui montre le routière vers "HUAWEI".

3. Quand Alice marche dans le centre commercial, l'application va affichier noir automatiquement pour économiser l'énergie. 

4. Quand Alice monte sur le troisième étage du centre commercial, l'application va afficher la carte associée. 

## Architecture Logicielle

![](https://github.com/huangshenyuan-unice/ELIM_2019/blob/b9cbb51e9d9632e51b8c2b86bb3b5e369837fae9/doc/dessin_Architecture.jpg?raw=true)
## Capteurs/équipement utilisés 

1. Bluetooth 5.0: Recevoir les signaux envoyées par iBeacon et s'agir à localisation intérieure

2. iBeacon 5.0：Envoyer les signaux afin de proposer les information de location

3. Capteur barométrique：Caculé avec les données reçues afin de calculer l'étage de l'utilisateur

4. Gyroscope：Détecter l'orientation de portable afin d'économiser l'énergie

5. Boussole：Détecter l'orientation de portable

6. GPS (à l'extérieur)：Localisation à l'extérieur

## Technologies de developpement

1. Back-end: Python

2. Front-end: Flutter (IOS/Android): cross-plateform

3. Base de donnée
    a. Redit: les données de cartes
    b. MySQL: donnée massive sur le trafic client (sera annalysé par Hadoop ...)
    
4. API
   Dans ce projet, nous utilisons GoogleMap API  au mode extérieur pour construire la carte extérieure. 
   
## Organisation 

1. Sprint1: Dans le sprint1, nous va principalement réaliser les deux modes. Pour le mode extérieur, nous allons fournir la carte extérieure. Et nous allons proposer la fontionnalité pour changer le mode. Dans le mode intérieure, nous affichons seulement une carte de centre commercial.  

2. Sprint2: Dans le sprint2, nous allons mocker les signaux de iBeacon pour la localisation à l'intérieur. De plus, nous pouvons téléchanger les informations de centre commercial.

3. Sprint3: Test avec vrai iBeacon. Nous allons filltre les signaux et optimiser l'algorithme.

4. Sprint4: Selon le résultat, nous allons réaliser un service pour envoyer la localisation 

