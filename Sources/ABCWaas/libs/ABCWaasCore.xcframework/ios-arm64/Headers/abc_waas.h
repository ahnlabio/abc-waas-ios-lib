#ifndef ABC_WAAS_H
#define ABC_WAAS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

    typedef void *auth_client_t;
    typedef void *waas_client_t;

    extern auth_client_t auth_client_create(const char *base_url,
                                            const char *platform,
                                            const char *access_key,
                                            const char *access_secret,
                                            const char *service_id);

    extern char *auth_client_send_login_code(auth_client_t client,
                                             const char *email,
                                             const char *lang);

    extern char *auth_client_verify_login_code(auth_client_t client,
                                               const char *email,
                                               const char *code);

    extern char *auth_client_login(auth_client_t client,
                                   const char *grant_type,
                                   const char *email,
                                   const char *password);

    extern void auth_client_free(auth_client_t client);

    extern void auth_string_free(char *s);

    // WaasClient 관련 함수
    extern waas_client_t waas_client_create(const char *base_url);

    extern char *waas_client_get_v3_wallet(waas_client_t client,
                                           const char *access_token);

    extern char *waas_client_get_v3_wallet_key(waas_client_t client,
                                               const char *access_token);

    extern char *waas_client_get_v3_wallet_user(waas_client_t client,
                                                const char *access_token);

    extern char *waas_client_get_v3_wallet_token(waas_client_t client,
                                                 const char *access_token,
                                                 const char *id);

    extern char *waas_client_post_v3_wallet_key(waas_client_t client,
                                                const char *access_token,
                                                const char *id,
                                                const char *curve,
                                                const char *public_key);

    extern void waas_client_free(waas_client_t client);

    extern void waas_string_free(char *s);

#ifdef __cplusplus
}
#endif

#endif /* ABC_WAAS_H */
