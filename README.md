# 🚀 VPS Info Script

Un script avansat pentru monitorizarea și gestionarea serverelor VPS, scris în Bash.

## 📋 Caracteristici

- 📊 Monitorizare în timp real a resurselor sistemului
  - CPU, RAM, Swap, și utilizare Disk
  - Informații detaliate despre sistem
  - Monitorizare bandwidth și I/O

- 🔧 Gestionare servicii
  - Instalare automată servicii (nginx, apache2, mysql, etc.)
  - Pornire/Oprire servicii
  - Monitorizare status

- 🔒 Securitate
  - Monitorizare încercări SSH suspecte
  - Verificare servicii active
  - Integrare cu fail2ban

- 💾 Backup și Actualizări
  - Verificare backup-uri recente
  - Sistem de actualizare automată
  - Gestionare pachete sistem

## 🛠️ Cerințe Sistem

- Sistem de operare: Linux (testat pe Ubuntu/Debian)
- Acces root sau sudo
- Pachete necesare:
  - sysstat (pentru iostat)
  - net-tools
  - lsof
  - systemd

## 📥 Instalare

1. Clonați repository-ul:
```bash
git clone https://github.com/arian222/vps-info.git
```

2. Acordați permisiuni de execuție:
```bash
cd vps-info
chmod +x vps_info.sh
```

3. Rulați scriptul:
```bash
sudo ./vps_info.sh
```

## 🎯 Utilizare

Scriptul oferă o interfață interactivă cu următoarele opțiuni:

1. Reîmprospătare informații sistem
2. Verificare actualizări
3. Verificare servicii
4. Verificare porturi active
5. Gestionare servicii
   - Instalare servicii noi
   - Pornire/Oprire servicii
   - Verificare status
6. Ieșire

## 🔧 Servicii Suportate

- NGINX
- Apache2
- MySQL
- PostgreSQL
- Docker
- Fail2ban
- SSH

## 🎨 Personalizare

Puteți personaliza scriptul modificând:
- Lista de servicii monitorizate
- Intervalele de actualizare
- Culorile interfeței
- Directoarele de backup verificate

## 🤝 Contribuție

Contribuțiile sunt binevenite! Pentru a contribui:

1. Fork acest repository
2. Creați un branch nou
3. Faceți modificările dorite
4. Creați un Pull Request

## 📝 Licență

Acest proiect este licențiat sub [MIT License](LICENSE)

## 👤 Autor

- Nume: ALECS
- GitHub: [@arian222](https://github.com/arian222)

## 🙏 Mulțumiri

Mulțumiri speciale tuturor contribuitorilor și comunității open source. 
