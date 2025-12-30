#ifndef INCLUDED_SOCK_ADDR_H
#define INCLUDED_SOCK_ADDR_H
#include "first.h"

#include "sys-socket.h"

#include "base_decls.h"
#include "buffer.h"


union sock_addr {
#ifdef HAVE_IPV6
	struct sockaddr_in6 ipv6;
#endif
	struct sockaddr_in ipv4;
#ifdef HAVE_SYS_UN_H
	struct sockaddr_un un;
#endif
	struct sockaddr plain;
};


__attribute_pure__
static inline int sock_addr_get_family (const sock_addr *saddr);
static inline int sock_addr_get_family (const sock_addr *saddr) {
	return saddr->plain.sa_family;
}

__attribute_pure__
unsigned short sock_addr_get_port (const sock_addr *saddr);

__attribute_pure__
int sock_addr_is_addr_wildcard (const sock_addr *saddr);

__attribute_pure__
int sock_addr_is_family_eq (const sock_addr *saddr1, const sock_addr *saddr2);

__attribute_pure__
int sock_addr_is_port_eq (const sock_addr *saddr1, const sock_addr *saddr2);

__attribute_pure__
int sock_addr_is_addr_eq (const sock_addr *saddr1, const sock_addr *saddr2);

#if 0
__attribute_pure__
int sock_addr_is_addr_port_eq (const sock_addr *saddr1, const sock_addr *saddr2);
#endif

__attribute_pure__

#endif
