/*
 *  ┳━┓┳━┓┳━┓┏┓┓┏━┓┳ ┳
 *  ┃━┃┣━ ┣━  ┃ ┃  ┃━┫
 *  ┇━┛┇  ┻━┛ ┇ ┗━┛┇ ┻
 *
 * Berkeley Fetch
 *
 * Tested on Ubuntu, Debian & Void. Won't work on anything else.
 *
 * install:
 *  $ printf "all: bfetch\n" > Makefile && make
 *
 * or:
 *  install tcc and run it without compiling
 *  $ tcc -run bfetch.c "TITLE"
 *
 * usage:
 *  $ bfetch "TITLE"
 *  $ bfetch "$(date)"
 *
 *  Most of this code was lifted from: https://github.com/ss7m/paleofetch
 *  Design lifted from: https://neil.computer/notes/neofetch/
 */

#include <arpa/inet.h>
#include <dirent.h>
#include <ifaddrs.h>
#include <limits.h>
#include <netdb.h>
#include <pwd.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/statvfs.h>
#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <unistd.h>

#define BLACK "\e[0;30m"
#define RED "\e[0;31m"
#define GREEN "\e[0;32m"
#define YELLOW "\e[0;33m"
#define BLUE "\e[0;34m"
#define PURPLE "\e[0;35m"
#define CYAN "\e[0;36m"
#define WHITE "\e[0;37m"
#define RESET "\e[0m"

#define BAR_LENGTH 20
#define BUF_SIZE 150

#define die(fmt, ...)                                                          \
  do {                                                                         \
    if (status != 0) {                                                         \
      fprintf(stderr, "sf: " fmt "\n", ##__VA_ARGS__);                         \
      exit(status);                                                            \
    }                                                                          \
  } while (0)

#define COUNT(x) (int)(sizeof x / sizeof *x)
#define REMOVE(A)                                                              \
  { (A), NULL, sizeof(A) - 1, 0 }
#define REPLACE(A, B)                                                          \
  { (A), (B), sizeof(A) - 1, sizeof(B) - 1 }

static char *get_cpu_info(), *get_os_info(), *get_local_ip(), *get_memory(),
    *get_disk_usage(), *get_uptime(), *get_packages(), *get_fqdn(),
    *get_bar_graph(long long used, long long total);

struct utsname uname_data;
struct sysinfo sys_info;
struct statvfs file_stats;
int status;

struct {
  char *substring;
  char *repl_str;
  size_t length;
  size_t repl_len;
} cpu_config[] = {
    REMOVE("(R)"),       REMOVE("(TM)"),     REMOVE("Dual-Core"),
    REMOVE("Quad-Core"), REMOVE("Six-Core"), REMOVE("Eight-Core"),
    REMOVE("8-Core"),    REMOVE("Core"),     REMOVE("CPU"),
    REMOVE("Processor"),
};

void truncate_spaces(char *str) {

  int src = 0, dst = 0;
  while (*(str + dst) == ' ')
    dst++;

  while (*(str + dst) != '\0') {
    *(str + src) = *(str + dst);
    if (*(str + (dst++)) == ' ')
      while (*(str + dst) == ' ')
        dst++;

    src++;
  }

  *(str + src) = '\0';
}

void remove_substring(char *str, const char *substring, size_t len) {
  // shift over the rest of the string to remove substring
  char *sub = strstr(str, substring);
  if (sub == NULL)
    return;

  int i = 0;
  do
    *(sub + i) = *(sub + i + len);
  while (*(sub + (++i)) != '\0');
}

void replace_substring(char *str, const char *sub_str, const char *repl_str,
                       size_t sub_len, size_t repl_len) {
  char buffer[BUF_SIZE / 2];
  char *start = strstr(str, sub_str);
  if (start == NULL)
    return; // substring not found

  // check if we have enough space for new substring
  if (strlen(str) - sub_len + repl_len >= BUF_SIZE / 2) {
    status = -1;
    die("new substring too long to replace");
  }

  strcpy(buffer, start + sub_len);
  strncpy(start, repl_str, repl_len);
  strcpy(start + repl_len, buffer);
}

static char *get_cpu_info() {

  FILE *cpuinfo = fopen("/proc/cpuinfo", "r");
  if (cpuinfo == NULL) {
    status = -1;
    die("Unable to open cpuinfo");
  }

  char *cpu_model = malloc(BUF_SIZE / 2);
  char *line = NULL;
  size_t len; // unused
  int num_cores = 0, cpu_freq, prec = 3;
  double freq;
  char freq_unit[] = "GHz";

  while (getline(&line, &len, cpuinfo) != -1) {
    num_cores += sscanf(line, "model name	: %[^\n@]", cpu_model);
    cpu_freq = sscanf(line, "cpu MHz : %lf", &freq);
  }
  cpu_freq = (int)freq;

  free(line);
  fclose(cpuinfo);

  if (cpu_freq < 1000) {
    freq = (double)cpu_freq;
    freq_unit[0] = 'M'; // make MHz from GHz
    prec = 0;           // show frequency as integer value
  } else {
    freq = cpu_freq / 1000.0; // convert MHz to GHz and cast to double

    while (cpu_freq % 10 == 0) {
      --prec;
      cpu_freq /= 10;
    }

    if (prec == 0)
      prec = 1; // we don't want zero decimal places
  }

  // Cleanup text & remove superfluous info
  for (int i = 0; i < COUNT(cpu_config); ++i) {
    if (cpu_config[i].repl_str == NULL) {
      remove_substring(cpu_model, cpu_config[i].substring,
                       cpu_config[i].length);
    } else {
      replace_substring(cpu_model, cpu_config[i].substring,
                        cpu_config[i].repl_str, cpu_config[i].length,
                        cpu_config[i].repl_len);
    }
  }

  char *cpu = malloc(BUF_SIZE);
  snprintf(cpu, BUF_SIZE, "%s (%d) @ %.*f%s", cpu_model, num_cores, prec, freq,
           freq_unit);
  free(cpu_model);

  truncate_spaces(cpu);

  if (num_cores == 0)
    *cpu = '\0';
  return cpu;
}

static char *get_memory() {

  int total, shared, memfree, buffers, cached, reclaimable;

  FILE *meminfo = fopen("/proc/meminfo", "r"); /* get infomation from meminfo */
  if (meminfo == NULL) {
    status = -1;
    die("Unable to open meminfo");
  }

  char *line = NULL; // allocation handled automatically by getline()
  size_t len;        // unused

  while (getline(&line, &len, meminfo) != -1) {
    // if sscanf doesn't find a match, pointer is untouched
    sscanf(line, "MemTotal: %d", &total);
    sscanf(line, "Shmem: %d", &shared);
    sscanf(line, "MemFree: %d", &memfree);
    sscanf(line, "Buffers: %d", &buffers);
    sscanf(line, "Cached: %d", &cached);
    sscanf(line, "SReclaimable: %d", &reclaimable);
  }

  free(line);

  fclose(meminfo);

  int used_kb = (total + shared - memfree - buffers - cached - reclaimable);
  int total_kb = total;
  int percentage = (int)(100 * (used_kb / (double)total_kb));

  char *memory_bar_graph = get_bar_graph(used_kb, total_kb);

  char *memory = malloc(BUF_SIZE);
  snprintf(memory, BUF_SIZE, "%s" GREEN " %dMiB / %dMiB (%d%%)",
           memory_bar_graph, used_kb / 1024, total_kb / 1024, percentage);
  free(memory_bar_graph);

  return memory;
}

static char *get_disk_usage() {

  char *disk_usage = malloc(BUF_SIZE);
  long total, used, free;
  int percentage;

  status = statvfs("/", &file_stats);
  die("Error getting disk usage for /");

  total = file_stats.f_blocks * file_stats.f_frsize;
  free = file_stats.f_bfree * file_stats.f_frsize;
  used = total - free;
  percentage = (used / (double)total) * 100;
  char *disk_bar_graph = get_bar_graph(used, total);

#define TO_GB(A) ((A) / (1024.0 * 1024 * 1024))
  snprintf(disk_usage, BUF_SIZE, "%s" GREEN " %.1fGiB / %.1fGiB (%d%%)",
           disk_bar_graph, TO_GB(used), TO_GB(total), percentage);
#undef TO_GB

  return disk_usage;
}

static char *get_os_info() {

  char *os = malloc(BUF_SIZE), *name = malloc(BUF_SIZE), *line = NULL;
  size_t len;
  FILE *os_release = fopen("/etc/os-release", "r");
  if (os_release == NULL) {
    status = -1;
    die("unable to open /etc/os-release");
  }

  while (getline(&line, &len, os_release) != -1) {
    if (sscanf(line, "PRETTY_NAME=\"%[^\"]+", name) > 0)
      break;
  }

  free(line);
  fclose(os_release);
  snprintf(os, BUF_SIZE, "%s %s", name, uname_data.machine);
  free(name);

  return os;
}

static char *get_uptime() {

  long seconds = sys_info.uptime;
  struct {
    char *name;
    int secs;
  } units[] = {
      {"day", 60 * 60 * 24},
      {"hour", 60 * 60},
      {"min", 60},
  };

  int n, len = 0;
  char *uptime = malloc(BUF_SIZE);
  for (int i = 0; i < 3; ++i) {
    if ((n = seconds / units[i].secs) || i == 2) // always print minutes
      len += snprintf(uptime + len, BUF_SIZE - len, "%d %s%s, ", n,
                      units[i].name, n != 1 ? "s" : "");
    seconds %= units[i].secs;
  }

  // null-terminate at the trailing comma
  uptime[len - 2] = '\0';
  return uptime;
}

static char *get_local_ip() {

  struct ifaddrs *ifaddr, *ifa;
  int family, s;
  char host[NI_MAXHOST];

  status = getifaddrs(&ifaddr);
  die("Error getting local IP address");

  for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
    if (ifa->ifa_addr == NULL)
      continue;

    family = ifa->ifa_addr->sa_family;

    if (family == AF_INET) {
      s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in), host,
                      NI_MAXHOST, NULL, 0, NI_NUMERICHOST);
      if (s != 0) {
        status = -1;
        die("Error getting local IP address");
      }

      if (strcmp(ifa->ifa_name, "lo") != 0) {
        freeifaddrs(ifaddr);
        return strdup(host);
      }
    }
  }

  freeifaddrs(ifaddr);
  return NULL;
}

static char *get_bar_graph(long long used, long long total) {

  int filled = (int)(((double)used / total) * BAR_LENGTH);
  int empty = BAR_LENGTH - filled;

  char *bar_graph = malloc(BAR_LENGTH * 3 + 3 + strlen(WHITE) +
                           strlen(RESET)); // Allocate memory for the bar graph
  char *bar_graph_ptr = bar_graph;

  strcpy(bar_graph_ptr, WHITE);
  bar_graph_ptr += strlen(WHITE);

  *bar_graph_ptr++ = '[';
  for (int i = 0; i < filled; i++) {
    memcpy(bar_graph_ptr, "\xe2\x96\x88", 3);
    bar_graph_ptr += 3;
  }
  for (int i = 0; i < empty; i++) {
    memcpy(bar_graph_ptr, "\xe2\x96\x91", 3);
    bar_graph_ptr += 3;
  }
  *bar_graph_ptr++ = ']';

  strcpy(bar_graph_ptr, RESET);
  bar_graph_ptr += strlen(RESET);
  *bar_graph_ptr = '\0'; // Null-terminate the string

  return bar_graph;
}

unsigned long count_occurrences(FILE *file, const char *substring) {

  char line[1024];
  unsigned long count = 0;

  while (fgets(line, sizeof(line), file)) {
    char *pos = line;
    while ((pos = strstr(pos, substring)) != NULL) {
      count++;
      pos += strlen(substring);
    }
  }

  return count;
}

static char *get_packages() {

  const char *voidDirPath = "/var/db/xbps";
  const char *debianFilePath = "/var/lib/dpkg/status";
  char fileName[2 * PATH_MAX + 2];
  bool isVoid = false;
  char *pkgs = malloc(BUF_SIZE);

  DIR *dir = opendir(voidDirPath);
  if (dir != NULL) {
    struct dirent *entry;

    while ((entry = readdir(dir)) != NULL) {
      if (entry->d_type == DT_REG && strncmp(entry->d_name, "pkgdb-", 6) == 0) {
        snprintf(fileName, sizeof(fileName), "%s/%s", voidDirPath,
                 entry->d_name);
        isVoid = true;
        break;
      }
    }
    closedir(dir);
  }

  if (!isVoid) {
    FILE *debianFile = fopen(debianFilePath, "r");
    if (debianFile != NULL) {
      strncpy(fileName, debianFilePath, sizeof(fileName));
      fclose(debianFile);
    }
  }

  if (strlen(fileName) == 0) {
    status = -1;
    die("No matching file found");
  }

  FILE *file = fopen(fileName, "r");
  if (file == NULL) {
    status = -1;
    die("Error opening file");
  }

  const char *searchString = isVoid ? "<string>installed</string>" : "Status: ";
  const char *pkgman = isVoid ? "xbps" : "dpkg";
  unsigned long count = count_occurrences(file, searchString);
  fclose(file);

  snprintf(pkgs, BUF_SIZE, "%ld (%s)", count, pkgman);
  return pkgs;
}

static char *get_fqdn() {

  status = uname(&uname_data);
  die("uname failed");

  struct addrinfo hints, *res;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_CANONNAME;

  status = getaddrinfo(uname_data.nodename, NULL, &hints, &res);
  die("getaddrinfo: %s\n", gai_strerror(status));

  return res->ai_canonname;
}

int main(int argc, char *argv[]) {

  status = uname(&uname_data);
  die("uname failed");
  status = sysinfo(&sys_info);
  die("sysinfo failed");

  char *cpu_info = get_cpu_info(), *os_info = get_os_info(),
       *local_ip = get_local_ip(), *mem_info = get_memory(),
       *disk_info = get_disk_usage(), *pkgs = get_packages(),
       *up_time = get_uptime(), *fqdn = get_fqdn(), *company = argv[1];

  if (argc < 2) {
    company = "BERKELEY FETCH";
  }

  printf(GREEN "\n%3s%s\n", "",
         "┌──────────────────────────────────────────────────────────┐");
  printf(GREEN "%3s│" WHITE " %-57s" GREEN "%s\n", "", company, "│");
  printf(GREEN "%3s│" YELLOW " %-57s" GREEN "%s\n", "",
         "Server Administration System", "│");
  printf(GREEN "%3s%s\n", "",
         "└──────────────────────────────────────────────────────────┘");
  printf(RED "%4s%-12s%s" GREEN "@" RED "%s\n\n", "", "USER",
         getpwuid(getuid())->pw_name, fqdn);
  printf(BLUE "%4s%-12s" GREEN "%s\n", "", "CPU", cpu_info);
  printf(BLUE "%4s%-12s" GREEN "%s\n", "", "OS", os_info);
  printf(BLUE "%4s%-12s" GREEN "%s %s\n", "", "Kernel", uname_data.sysname,
         uname_data.release);
  printf(BLUE "%4s%-12s" GREEN "%s\n", "", "Packages", pkgs);
  printf(BLUE "%4s%-12s" GREEN "%s\n", "", "Local IP", local_ip);
  printf(BLUE "%4s%-12s" GREEN "%s\n\n", "", "Uptime", up_time);
  printf(BLUE "%4s%-12s%s\n", "", "Memory", mem_info);
  printf(BLUE "%4s%-12s%s\n", "", "Disk (/)", disk_info);
  printf(RESET);

  free(cpu_info);
  free(os_info);
  free(pkgs);
  free(local_ip);
  free(up_time);
  free(mem_info);
  free(disk_info);
  free(fqdn);

  return 0;
}
