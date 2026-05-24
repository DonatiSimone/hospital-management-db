```sql
-- =========================
-- REPARTO
-- =========================
CREATE TABLE Reparto (
    id_reparto SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    ubicazione TEXT,
    telefono VARCHAR(20),
    capo_medico_id INTEGER
);

-- =========================
-- MEDICO
-- =========================
CREATE TABLE Medico (
    id_medico SERIAL PRIMARY KEY,
    albo_numero INTEGER UNIQUE NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    specializzazione VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    attivo BOOLEAN,
    id_reparto INTEGER,

    FOREIGN KEY (id_reparto) REFERENCES Reparto(id_reparto)
);

ALTER TABLE Reparto
ADD CONSTRAINT fk_capo_medico
FOREIGN KEY (capo_medico_id) REFERENCES Medico(id_medico);

-- =========================
-- PAZIENTE
-- =========================
CREATE TABLE Paziente (
    id_paziente SERIAL PRIMARY KEY,
    codice_fiscale CHAR(16) UNIQUE NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    data_nascita DATE,
    sesso CHAR(1),
    telefono VARCHAR(20),
    email VARCHAR(100),
    indirizzo TEXT,
    medico_base_id INTEGER,
    note_cliniche_sint TEXT,

    FOREIGN KEY (medico_base_id) REFERENCES Medico(id_medico)
);

-- =========================
-- AMBULATORIO
-- =========================
CREATE TABLE Ambulatorio (
    id_ambulatorio SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    sede VARCHAR(100),
    specialita VARCHAR(100),
    id_reparto INTEGER,

    UNIQUE (nome, sede),

    FOREIGN KEY (id_reparto) REFERENCES Reparto(id_reparto)
);

-- =========================
-- CALENDARIO SLOT
-- =========================
CREATE TABLE Calendario_slot (
    id_slot SERIAL PRIMARY KEY,
    id_ambulatorio INTEGER,
    inizio TIMESTAMP,
    fine TIMESTAMP,
    stato VARCHAR(20),
    fonte VARCHAR(50),
    id_medico INTEGER,

    UNIQUE (id_ambulatorio, inizio),

    FOREIGN KEY (id_ambulatorio) REFERENCES Ambulatorio(id_ambulatorio),
    FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
);

-- =========================
-- VISITA TIPO
-- =========================
CREATE TABLE Visita_tipo (
    id_tipo SERIAL PRIMARY KEY,
    codice_prestazione VARCHAR(50) UNIQUE NOT NULL
);

-- =========================
-- UTENTE
-- =========================
CREATE TABLE Utente (
    id_utente SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    ruolo VARCHAR(20),
    id_medico INTEGER,

    FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
);

-- =========================
-- PRENOTAZIONE
-- =========================
CREATE TABLE Prenotazione (
    id_prenotazione SERIAL PRIMARY KEY,

    id_paziente INTEGER NOT NULL,
    id_slot INTEGER NOT NULL,
    id_tipo INTEGER,
    id_utente INTEGER,

    priorita VARCHAR(20),
    motivo TEXT,
    stato VARCHAR(20),

    UNIQUE (id_paziente, id_slot),

    FOREIGN KEY (id_paziente) REFERENCES Paziente(id_paziente),
    FOREIGN KEY (id_slot) REFERENCES Calendario_slot(id_slot),
    FOREIGN KEY (id_tipo) REFERENCES Visita_tipo(id_tipo),
    FOREIGN KEY (id_utente) REFERENCES Utente(id_utente)
);

-- =========================
-- VISITA
-- =========================
CREATE TABLE Visita (
    id_visita SERIAL PRIMARY KEY,
    id_prenotazione INTEGER UNIQUE,

    anamnesi TEXT,
    sintomi TEXT,
    esame_obiettivo TEXT,
    vitali TEXT,
    inizio TIMESTAMP,
    fine TIMESTAMP,

    FOREIGN KEY (id_prenotazione) REFERENCES Prenotazione(id_prenotazione)
);

-- =========================
-- ESAME
-- =========================
CREATE TABLE Esame (
    id_esame SERIAL PRIMARY KEY,
    id_visita INTEGER,
    codice_loinc VARCHAR(50),

    programmato_per TIMESTAMP,
    eseguito_il TIMESTAMP,
    tipo VARCHAR(100),
    stato VARCHAR(20),
    note TEXT,

    UNIQUE (id_visita, codice_loinc),

    FOREIGN KEY (id_visita) REFERENCES Visita(id_visita)
);

-- =========================
-- REFERTO
-- =========================
CREATE TABLE Referto (
    id_referto SERIAL PRIMARY KEY,
    id_esame INTEGER,
    versione INTEGER,
    dati_strutturati TEXT,
    allegato TEXT,
    id_medico INTEGER,

    UNIQUE (id_esame, versione),

    FOREIGN KEY (id_esame) REFERENCES Esame(id_esame),
    FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
);

-- =========================
-- DIZIONARIO DIAGNOSI
-- =========================
CREATE TABLE Dizionario_diagnosi (
    id_diagnosi SERIAL PRIMARY KEY,
    codice_diagnosi VARCHAR(50) UNIQUE,
    descrizione TEXT,
    sistema VARCHAR(50)
);

-- =========================
-- DIAGNOSI
-- =========================
CREATE TABLE Diagnosi (
    id_diagnosi_istanza SERIAL PRIMARY KEY,
    id_visita INTEGER,
    id_diagnosi INTEGER,
    id_medico INTEGER,
    timestamp TIMESTAMP,
    stato VARCHAR(20),

    FOREIGN KEY (id_visita) REFERENCES Visita(id_visita),
    FOREIGN KEY (id_diagnosi) REFERENCES Dizionario_diagnosi(id_diagnosi),
    FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
);

-- =========================
-- AI SUGGERIMENTO
-- =========================
CREATE TABLE AI_suggerimento (
    id_suggerimento SERIAL PRIMARY KEY,
    id_visita INTEGER,
    id_diagnosi INTEGER,
    timestamp TIMESTAMP,

    modello_versione VARCHAR(50),
    confidenza FLOAT,
    spiegazione TEXT,

    FOREIGN KEY (id_visita) REFERENCES Visita(id_visita),
    FOREIGN KEY (id_diagnosi) REFERENCES Dizionario_diagnosi(id_diagnosi)
);

-- =========================
-- AI AZIONE MEDICO
-- =========================
CREATE TABLE AI_azione_medico (
    id_azione SERIAL PRIMARY KEY,
    id_suggerimento INTEGER,
    id_medico INTEGER,
    timestamp TIMESTAMP,
    azione VARCHAR(50),
    motivazione TEXT,

    FOREIGN KEY (id_suggerimento) REFERENCES AI_suggerimento(id_suggerimento),
    FOREIGN KEY (id_medico) REFERENCES Medico(id_medico)
);

-- =========================
-- CONSENSO
-- =========================
CREATE TABLE Consenso (
    id_consenso SERIAL PRIMARY KEY,
    id_paziente INTEGER,
    tipo VARCHAR(50),
    valido_dal DATE,
    valido_al DATE,
    note TEXT,

    FOREIGN KEY (id_paziente) REFERENCES Paziente(id_paziente)
);

-- =========================
-- LOG
-- =========================
CREATE TABLE Log (
    id_log SERIAL PRIMARY KEY,
    id_utente INTEGER,
    timestamp TIMESTAMP,
    entita VARCHAR(50),
    azione VARCHAR(50),
    modifiche TEXT,

    FOREIGN KEY (id_utente) REFERENCES Utente(id_utente)
);

-- =========================
-- ALLEGATO VISITA
-- =========================
CREATE TABLE Allegato_visita (
    id_allegato SERIAL PRIMARY KEY,
    id_visita INTEGER,
    documento TEXT,
    tipo VARCHAR(50),
    descrizione TEXT,

    FOREIGN KEY (id_visita) REFERENCES Visita(id_visita)
);
```
