#!/bin/bash

# Culori și formatare
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Setează timpul de start
start_time=$(date +%s)

# Funcție pentru animație de loading
loading() {
    local duration=$1
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local sleep_duration=0.5
    local end=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end ]; do
        for (( i=0; i<${#chars}; i++ )); do
            echo -en "\r${BLUE}${chars:$i:1} Se încarcă sistemul...${NC}"
            sleep $sleep_duration
        done
    done
    echo -en "\r\033[K"
}

# Funcție pentru afișarea titlului cu animație
print_title() {
    clear
    echo -e "\n"
    local title=(
        "${CYAN}${BOLD}╔════════════════════════════════════════╗${NC}"
        "${CYAN}${BOLD}║        Informații Server VPS            ║${NC}"
        "${CYAN}${BOLD}╚════════════════════════════════════════╝${NC}"
    )
    
    for line in "${title[@]}"; do
        echo -en "$line"
        sleep 0.1
        echo
    done
    echo
}

# Funcție pentru afișarea informațiilor cu animație
print_info() {
    local label=$1
    local value=$2
    echo -ne "${YELLOW}${BOLD}➜ ${NC}${BOLD}$label:${NC} "
    for (( i=0; i<${#value}; i++ )); do
        echo -n "${value:$i:1}"
        sleep 0.05
    done
    echo
}

# Funcție pentru afișarea barei de progres
show_progress() {
    local title=$1
    local current=$2
    local max=$3
    local width=40
    
    # Verifică și corectează valoarea current dacă e invalidă
    if [[ ! $current =~ ^[0-9]+$ ]] || [ $current -lt 0 ]; then
        current=0
    elif [ $current -gt $max ]; then
        current=$max
    fi
    
    local percentage=$((current * 100 / max))
    local filled=$((width * current / max))
    local empty=$((width - filled))
    
    printf "${WHITE}%-20s [${GREEN}" "$title"
    printf "%-${filled}s${NC}${RED}%-${empty}s${WHITE}] %d%%${NC}\n" | tr ' ' '█' | tr ' ' '░'
}

# Funcție pentru afișarea ceasului digital
show_clock() {
    local time=$(date +"%H:%M:%S")
    local date=$(date +"%d-%m-%Y")
    echo -e "${PURPLE}${BOLD}╔════════════════════╗${NC}"
    echo -e "${PURPLE}${BOLD}║    ${WHITE}$time${PURPLE}    ║${NC}"
    echo -e "${PURPLE}${BOLD}║    ${WHITE}$date${PURPLE}    ║${NC}"
    echo -e "${PURPLE}${BOLD}╚════════════════════╝${NC}\n"
}

# Funcție pentru monitorizarea serviciilor importante
check_services() {
    echo -e "\n${CYAN}${BOLD}=== Status Servicii Importante ===${NC}"
    local services=("sshd" "nginx" "apache2" "mysql" "postgresql" "docker" "fail2ban")
    
    for service in "${services[@]}"; do
        if systemctl is-active "$service" &>/dev/null; then
            echo -e "${GREEN}${BOLD}✓${NC} $service ${GREEN}activ${NC}"
        else
            echo -e "${RED}${BOLD}✗${NC} $service ${RED}inactiv${NC}"
        fi
        sleep 0.1
    done
}

# Funcție pentru afișarea ultimelor conexiuni SSH suspecte
show_suspicious_logins() {
    echo -e "\n${CYAN}${BOLD}=== Ultimele Încercări SSH Suspecte ===${NC}"
    local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "Nu există informații")
    if [ "$failed_logins" != "Nu există informații" ]; then
        echo -e "${RED}${BOLD}Ultimele 5 încercări eșuate:${NC}"
        echo "$failed_logins" | while read -r line; do
            echo -e "${RED}➜${NC} $line"
            sleep 0.1
        done
    else
        echo -e "${GREEN}Nu s-au găsit încercări suspecte recente${NC}"
    fi
}

# Funcție pentru monitorizarea porturilor active
check_ports() {
    echo -e "\n${CYAN}${BOLD}=== Porturi Active ===${NC}"
    echo -e "${YELLOW}${BOLD}Port\tProtocol\tServiciu${NC}"
    netstat -tuln | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -n | while read port; do
        if [ ! -z "$port" ]; then
            service=$(lsof -i :$port 2>/dev/null | tail -1 | awk '{print $1}')
            proto=$(netstat -tuln | grep ":$port" | awk '{print $1}')
            echo -e "${GREEN}$port${NC}\t$proto\t\t${YELLOW}$service${NC}"
            sleep 0.1
        fi
    done
}

# Funcție pentru monitorizarea proceselor consumatoare de resurse
show_top_processes() {
    echo -e "\n${CYAN}${BOLD}=== Top 5 Procese CPU/Memory ===${NC}"
    echo -e "${ORANGE}${BOLD}CPU:${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-20s %5.2f%%\n", $11, $3}' | while read line; do
        echo -e "${YELLOW}➜${NC} $line"
        sleep 0.1
    done
    
    echo -e "\n${ORANGE}${BOLD}Memory:${NC}"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-20s %5.2f%%\n", $11, $4}' | while read line; do
        echo -e "${YELLOW}➜${NC} $line"
        sleep 0.1
    done
}

# Funcție pentru verificarea backup-urilor recente
check_backups() {
    echo -e "\n${CYAN}${BOLD}=== Status Backup-uri ===${NC}"
    local backup_dirs=("/backup" "/var/backups" "/home/*/backup")
    local found_backups=false
    
    for dir in "${backup_dirs[@]}"; do
        if ls $dir 2>/dev/null >/dev/null; then
            found_backups=true
            echo -e "${GREEN}${BOLD}Backup-uri în $dir:${NC}"
            find $dir -type f -mtime -7 -ls 2>/dev/null | 
            awk '{printf "%-50s %10s %s %s %s\n", $11, $7, $6, $7, $8}' |
            while read line; do
                echo -e "${YELLOW}➜${NC} $line"
                sleep 0.1
            done
        fi
    done
    
    if [ "$found_backups" = false ]; then
        echo -e "${RED}Nu s-au găsit backup-uri recente${NC}"
    fi
}

# Funcție pentru actualizarea sistemului
update_system() {
    echo -e "\n${CYAN}${BOLD}=== Actualizare Sistem ===${NC}"
    
    echo -e "${YELLOW}${BOLD}Verificare actualizări disponibile...${NC}"
    if apt-get update 2>&1 | grep -q '^[WE]:'; then
        echo -e "${RED}Eroare la verificarea actualizărilor!${NC}"
        return 1
    fi
    
    # Verifică dacă există actualizări disponibile
    updates=$(apt-get -s upgrade | grep -P '^\d+ upgraded' | cut -d" " -f1)
    security_updates=$(apt-get -s upgrade | grep -i security | wc -l)
    
    if [ "$updates" -gt 0 ]; then
        echo -e "${GREEN}${BOLD}$updates${NC} pachete pot fi actualizate"
        echo -e "${RED}${BOLD}$security_updates${NC} actualizări de securitate"
        
        echo -e "\n${YELLOW}Doriți să instalați actualizările? [y/N]${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Se instalează actualizările...${NC}"
            apt-get upgrade -y
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}${BOLD}Sistemul a fost actualizat cu succes!${NC}"
                
                # Verifică dacă este necesară repornirea
                if [ -f /var/run/reboot-required ]; then
                    echo -e "${RED}${BOLD}Este necesară repornirea sistemului!${NC}"
                fi
            else
                echo -e "${RED}${BOLD}Eroare la actualizarea sistemului!${NC}"
            fi
        else
            echo -e "${YELLOW}Actualizare anulată.${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}Sistemul este la zi!${NC}"
    fi
}

# Funcție pentru instalarea serviciilor
install_service() {
    local service=$1
    echo -e "\n${CYAN}${BOLD}=== Instalare $service ===${NC}"
    
    if ! command -v $service &> /dev/null; then
        echo -e "${YELLOW}Se instalează $service...${NC}"
        case $service in
            nginx)
                apt-get install -y nginx
                ;;
            apache2)
                apt-get install -y apache2
                ;;
            mysql)
                apt-get install -y mysql-server
                ;;
            postgresql)
                apt-get install -y postgresql postgresql-contrib
                ;;
            docker)
                apt-get install -y docker.io
                systemctl enable docker
                ;;
            fail2ban)
                apt-get install -y fail2ban
                cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
                ;;
            *)
                echo -e "${RED}Serviciul $service nu este suportat pentru instalare${NC}"
                return 1
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}${BOLD}$service a fost instalat cu succes!${NC}"
            systemctl start $service
            systemctl enable $service
        else
            echo -e "${RED}${BOLD}Eroare la instalarea $service!${NC}"
        fi
    else
        echo -e "${GREEN}$service este deja instalat${NC}"
    fi
}

# Funcție pentru gestionarea serviciilor
manage_service() {
    local service=$1
    local action=$2
    
    case $action in
        start)
            systemctl start $service
            ;;
        stop)
            systemctl stop $service
            ;;
        restart)
            systemctl restart $service
            ;;
        status)
            systemctl status $service
            ;;
    esac
}

# Funcție pentru meniul de gestionare a serviciilor
manage_services_menu() {
    while true; do
        echo -e "\n${CYAN}${BOLD}=== Gestionare Servicii ===${NC}"
        echo -e "${YELLOW}${BOLD}Servicii disponibile:${NC}"
        echo -e "${WHITE}1. nginx${NC}"
        echo -e "${WHITE}2. apache2${NC}"
        echo -e "${WHITE}3. mysql${NC}"
        echo -e "${WHITE}4. postgresql${NC}"
        echo -e "${WHITE}5. docker${NC}"
        echo -e "${WHITE}6. fail2ban${NC}"
        echo -e "${WHITE}7. Înapoi la meniul principal${NC}"
        
        echo -ne "\n${CYAN}Alegeți un serviciu (1-7): ${NC}"
        read -r service_choice
        
        if [ "$service_choice" == "7" ]; then
            break
        fi
        
        local service_name=""
        case $service_choice in
            1) service_name="nginx" ;;
            2) service_name="apache2" ;;
            3) service_name="mysql" ;;
            4) service_name="postgresql" ;;
            5) service_name="docker" ;;
            6) service_name="fail2ban" ;;
            *) echo -e "${RED}Opțiune invalidă!${NC}"; continue ;;
        esac
        
        echo -e "\n${YELLOW}${BOLD}Acțiuni disponibile pentru $service_name:${NC}"
        echo -e "${WHITE}1. Instalare${NC}"
        echo -e "${WHITE}2. Pornire${NC}"
        echo -e "${WHITE}3. Oprire${NC}"
        echo -e "${WHITE}4. Repornire${NC}"
        echo -e "${WHITE}5. Status${NC}"
        
        echo -ne "\n${CYAN}Alegeți o acțiune (1-5): ${NC}"
        read -r action_choice
        
        case $action_choice in
            1) install_service $service_name ;;
            2) manage_service $service_name "start" ;;
            3) manage_service $service_name "stop" ;;
            4) manage_service $service_name "restart" ;;
            5) manage_service $service_name "status" ;;
            *) echo -e "${RED}Opțiune invalidă!${NC}" ;;
        esac
        
        echo -e "\n${YELLOW}Apăsați ENTER pentru a continua...${NC}"
        read
    done
}

# Verifică dacă rulează ca root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Acest script trebuie rulat ca root (folosiți sudo)${NC}"
   exit 1
fi

# Verifică dependințele necesare
for cmd in iostat ip free df who last; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Eroare: Comanda '$cmd' nu este instalată. Instalați pachetul necesar.${NC}"
        exit 1
    fi
done

# Afișare titlu și ceas
print_title
show_clock

# Animație de loading inițială
echo -e "${BLUE}Se colectează informațiile despre server...${NC}"
loading 3

# Colectare informații sistem pentru Linux
hostname=$(hostname)
os=$(cat /etc/os-release 2>/dev/null | grep "PRETTY_NAME" | cut -d'"' -f2)
kernel=$(uname -r)
cpu=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')
cpu_cores=$(nproc)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
mem_total=$(free -h | awk '/^Mem:/ {print $2}')
mem_used=$(free -h | awk '/^Mem:/ {print $3}')
mem_free=$(free -h | awk '/^Mem:/ {print $4}')
mem_usage_percent=$(free | awk '/^Mem:/ {if($2>0) print int($3/$2 * 100); else print 0}')
swap_total=$(free -h | awk '/^Swap:/ {print $2}')
swap_used=$(free -h | awk '/^Swap:/ {print $3}')
swap_usage_percent=$(free | awk '/^Swap:/ {if($2>0) print int($3/$2 * 100); else print 0}')
disk_info=$(df -h / | awk 'NR==2 {print $2 " total, " $3 " folosit, " $4 " liber"}')
disk_usage_percent=$(df -h / | awk 'NR==2 {print int($5)}')
uptime=$(uptime -p)
load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
ip_address=$(hostname -I | awk '{print $1}')
processes=$(ps aux | wc -l)
users_logged=$(who | wc -l)
last_login=$(last -n 1 | head -n1 | awk '{print $1" "$3" "$4" "$5" "$6" "$7}' 2>/dev/null || echo "Nu există informații")
disk_io=$(iostat -d -h 1 1 | awk 'NR==4 {printf "Read: %s/s, Write: %s/s", $3, $4}' 2>/dev/null || echo "Informație indisponibilă")
network_interfaces=$(ip -o link show | awk -F': ' '{print $2}' | tr '\n' ', ' | sed 's/,$//')
rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo "0")
tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo "0")
bandwidth=$(printf "RX: %.2f MB, TX: %.2f MB" "$((rx_bytes/1024/1024))" "$((tx_bytes/1024/1024))")

# Afișare informații cu animații
print_info "Hostname" "$hostname"
print_info "IP Address" "$ip_address"
print_info "Sistem de Operare" "$os"
print_info "Kernel" "$kernel"
print_info "Procesor" "$cpu"
print_info "Nuclee CPU" "$cpu_cores"

echo -e "\n${CYAN}${BOLD}=== Utilizare Resurse ===${NC}"
show_progress "CPU" "$cpu_usage" "100"
show_progress "RAM" "$mem_usage_percent" "100"
show_progress "Swap" "$swap_usage_percent" "100"
show_progress "Disk" "$disk_usage_percent" "100"

echo -e "\n${CYAN}${BOLD}=== Informații Detaliate ===${NC}"
print_info "Memorie RAM" "$mem_used folosită din $mem_total (liber: $mem_free)"
print_info "Swap" "$swap_used folosit din $swap_total"
print_info "Spațiu Disk" "$disk_info"
print_info "I/O Disk" "$disk_io"
print_info "Bandwidth" "$bandwidth"
print_info "Uptime" "$uptime"
print_info "Încărcare Sistem" "$load_avg"
print_info "Procese Active" "$processes"
print_info "Utilizatori Conectați" "$users_logged"
print_info "Ultima Autentificare" "$last_login"
print_info "Interfețe Rețea" "$network_interfaces"

# După afișarea informațiilor existente, adăugăm noile funcții
check_services
show_suspicious_logins
check_ports
show_top_processes
check_backups
update_system

while true; do
    echo -e "\n${YELLOW}${BOLD}Opțiuni disponibile:${NC}"
    echo -e "${WHITE}1. Reîmprospătează informațiile${NC}"
    echo -e "${WHITE}2. Verifică actualizări${NC}"
    echo -e "${WHITE}3. Verifică servicii${NC}"
    echo -e "${WHITE}4. Verifică porturi${NC}"
    echo -e "${WHITE}5. Gestionare servicii${NC}"
    echo -e "${WHITE}6. Ieșire${NC}"
    echo -ne "\n${CYAN}Alegeți o opțiune (1-6): ${NC}"
    read -r choice

    case $choice in
        1)
            clear
            print_title
            show_clock
            loading 3
            # Reîmprospătează toate informațiile
            ;;
        2)
            update_system
            ;;
        3)
            check_services
            ;;
        4)
            check_ports
            ;;
        5)
            manage_services_menu
            ;;
        6)
            echo -e "\n${GREEN}La revedere!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Opțiune invalidă!${NC}"
            ;;
    esac
    
    echo -e "\n${YELLOW}Apăsați ENTER pentru a continua...${NC}"
    read
done

# Footer modern
echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║      Script generat cu ❤️  by ALECS     ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════╝${NC}"

# Calculează și afișează timpul de execuție corect
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "\n${GREEN}Timp de execuție: ${execution_time} secunde${NC}\n" 