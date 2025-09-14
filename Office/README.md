# 📦 Installation de la suite Microsoft Office

Ce guide explique comment installer la suite **Microsoft Office** (Word, Excel, PowerPoint, etc.) sur votre ordinateur.

---

## 🔽 Étape 1 : Télécharger les fichiers nécessaires

Deux options sont possibles :

1. Télécharger directement le **Setup X86 ou X64** (selon l’architecture de votre PC), puis exécuter le fichier.  
**OU**  
2. Télécharger les fichiers suivants :  
   - setup.exe  
   - config.xml

---

## 📂 Étape 2 : Ouvrir l’invite de commande

1. Placez les fichiers téléchargés dans un **dossier de destination** (par exemple : C:\Office).  
2. Ouvrez un **Invite de commandes en mode Administrateur**.  
3. Déplacez-vous dans le dossier de destination avec la commande :  

   cd C:\Office

---

## ⚙️ Étape 3 : Télécharger les fichiers d’installation

Exécutez la commande suivante :

   setup.exe /download config.xml

👉 Patientez quelques minutes. Le téléchargement est terminé lorsque l’invite revient à la ligne.

---

## 🚀 Étape 4 : Installer Office

Une fois le téléchargement fini, lancez l’installation avec :

   setup.exe /configure config.xml

---

✅ Votre suite Office sera installée et prête à l’utilisation !  

---

✍️ *Astuce : Assurez-vous d’avoir une connexion Internet stable pendant le téléchargement et l’installation.*
