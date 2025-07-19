// Inclusion des bibliothèques nécessaires
#include <WiFi.h>                
#include <WebServer.h>           // créer un serveur HTTP
#include <DHT.h>                 // lire les données du capteur DHT (température et humidité)
#include <ArduinoJson.h>         // Pour formater les données JSON

// Définition des broches utilisées
#define DHTPIN 4                 // Broche connectée au capteur DHT22
#define DHTTYPE DHT22           // Définir le type de capteur DHT (DHT22)
#define SOIL_MOISTURE_PIN 34    // Broche analogique pour lire le capteur d'humidité du sol
#define RELAY_PIN 2             // Broche connectée au module relais (pompe)

const char* ssid="Redmi Note 13";         
const char* password="chahd412004";      

WebServer Server(80);            // Créer un serveur HTTP sur le port 80

DHT dht(DHTPIN ,DHTTYPE);        // Initialisation du capteur DHT

// Variables globales pour stocker les mesures
int temperature = 0;             
int humidity = 0;
int moisturePercent=0;          // Taux d'humidité du sol en pourcentage


void setup() {
  dht.begin();                             // Initialisation du capteur DHT
  pinMode(RELAY_PIN, OUTPUT);             
  digitalWrite(RELAY_PIN, LOW);           // Éteindre la pompe au démarrage

  Serial.begin(115200);                   
  delay(1000);                             

  Serial.println("\n");
  WiFi.begin(ssid, password);             // Connexion au réseau WiFi
  Serial.println("*** Tentative de connexion ***");

  // Attente jusqu'à la connexion WiFi
  while(WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(100);
  }

  Serial.println("\n");
  Serial.println("Connexion etablie ! ");
  Serial.println("Adresse IP: ");
  Serial.print(WiFi.localIP());           // Affiche l'adresse IP obtenue

  // Définir le gestionnaire de requête pour /status
  Server.on("/status", HTTP_GET, handleStatusRequest);

  Server.begin();                         // Lancer le serveur HTTP
  Serial.println("Serveur HTTP démarré.");
}

void loop() {
  Server.handleClient();                  // Gérer les requêtes entrantes depuis l'application Flutter
  DHT_SoilSensor();                       // Lire les données des capteurs

  // Ne continuer que si les valeurs sont valides
  if (!isnan(temperature) && !isnan(humidity)) {
    auto_irrigation();                   
  } else {
    Serial.println("Lecture invalide des capteurs.");
  }

  delay(2000);                         
}

// Fonction pour lire les capteurs de température, humidité de l'air et du sol
void DHT_SoilSensor(){
  temperature = dht.readTemperature();      
  humidity = dht.readHumidity();               
  soilMoisture = analogRead(SOIL_MOISTURE_PIN);  

  // Convertir la lecture analogique (0–4095) en pourcentage
  moisturePercent = map(soilMoisture, 0, 4095, 100, 0); 

  // Vérification si les valeurs sont valides
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Erreur de lecture du capteur DHT22  !");
    return;
  }

  // Affichage des données sur le moniteur série
  Serial.println("\n\n");
  Serial.println("===== Mesures ===== ");
  Serial.print("Température de l'air: ");
  Serial.print(temperature);
  Serial.println("°c");

  Serial.print("Humidité de l'air: ");
  Serial.print(humidity);
  Serial.println("%");


  Serial.print("Humidité du sol (%): ");
  Serial.println(moisturePercent);
  Serial.println("================");
}

// Fonction d'irrigation automatique selon l'humidité du sol
void auto_irrigation(){
  if (moisturePercent < 30) {                
    Serial.println("le sol est sec. ");
    digitalWrite(RELAY_PIN, HIGH);         
    Serial.println("Pompe activée !");
  } else {
    Serial.println("le sol est humide. ");
    digitalWrite(RELAY_PIN, LOW);       
    Serial.println("Pompe désactivée !");
  }
}

// Fonction pour répondre à la requête HTTP /status (appelée par Flutter)
void handleStatusRequest() {
  StaticJsonDocument<200> doc;                // Création du document JSON

  doc["temperature"] = temperature;           // Ajouter la température
  doc["humidity"] = humidity;                 // Ajouter l’humidité de l’air
  doc["soil_moisture_percent"] = moisturePercent; // Ajouter l’humidité du sol en %
  doc["pump_status"] = (digitalRead(RELAY_PIN) == HIGH) ? "ON" : "OFF"; // Ajouter l'état de la pompe

  String responseJson;                        
  serializeJson(doc, responseJson);           // Convertir l'objet JSON en String

  Server.send(200, "application/json", responseJson); // Envoyer la réponse JSON au client
}
