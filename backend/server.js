const express = require('express');
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Créer l'application Express
const app = express();
const uploadImages = multer({ dest: 'mairie/photos/' }); 
const uploadPDFs = multer({ dest: 'mairie/pdf/' }); 
const port = 3333;

// Configurer la connexion à la base de données
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'pnco'
});

// Connexion à la base de données
connection.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à la base de données:', err.stack);
    return;
  }
  console.log('Connecté à la base de données avec l\'ID', connection.threadId);
});

// Route pour récupérer tous les projets
app.get('/projets', (req, res) => {
  const sql = 'SELECT * FROM projets';
  connection.query(sql, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des projets:', err.stack);
      res.status(500).send('Erreur serveur');
      return;
    }
    res.json(results);
  });
});

app.get('/projet/:id', (req, res) => {
  const id = req.params.id;
  const sql = 'SELECT * FROM projets WHERE Numero = ?';
  connection.query(sql, [id], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des projets:', err.stack);
      res.status(500).send('Erreur serveur');
      return;
    }
    res.json(results);
  });
});

// Route pour récupérer tous les sous-projets
app.get('/sous_projets', (req, res) => {
  const sql = 'SELECT * FROM sous_projets';
  connection.query(sql, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des sous-projets:', err.stack);
      res.status(500).send('Erreur serveur');
      return;
    }
    res.json(results);
  });
});

app.get('/sous_projet/:idProjet', (req, res) => {
  const idProjet = req.params.idProjet;
  const sql = 'SELECT * FROM sous_projets WHERE numeroProjet = ?';
  connection.query(sql, [idProjet], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des sous-projets pour le projet:', err.stack);
      res.status(500).send('Erreur serveur');
      return;
    }
    res.json(results);
  });
});

// Route pour recevoir une image
app.post('/upload/image', uploadImages.single('file'), (req, res) => {
  const file = req.file;
  if (!file) {
    return res.status(400).send('Aucun fichier reçu');
  }
  const destPath = path.join(__dirname, 'mairie/photos', file.originalname);
  fs.rename(file.path, destPath, (err) => {
    if (err) {
      console.error('Erreur lors du déplacement du fichier:', err.stack);
      return res.status(500).send('Erreur lors du traitement du fichier');
    }
    res.status(200).send('Fichier reçu et déplacé avec succès');
  });
});

// Route pour recevoir un fichier PDF
app.post('/upload/pdf', uploadPDFs.single('file'), (req, res) => {
  const file = req.file;
  if (!file) {
    return res.status(400).send('Aucun fichier reçu');
  }
  const destPath = path.join(__dirname, 'mairie/pdf', file.originalname);
  fs.rename(file.path, destPath, (err) => {
    if (err) {
      console.error('Erreur lors du déplacement du fichier:', err.stack);
      return res.status(500).send('Erreur lors du traitement du fichier');
    }
    res.status(200).send('Fichier reçu et déplacé avec succès');
  });
});

// Démarrer le serveur
app.listen(port, () => {
  console.log(`Serveur en cours d'exécution sur http://localhost:${port}`);
});
