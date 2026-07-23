-- Buscar RMs que reproducen el bug IA Thymeleaf:
-- lista principal de protocolos VACÍA + al menos 1 protocolo manual en inf3.
--
-- Ejecutar TODO el fichero de una vez (Ctrl+Enter sobre la sentencia completa).
-- PostgreSQL / esquema vig_salud (InformesMigrationDao).

SELECT
    r.rm_id,
    COALESCE(r.version, 0) AS version,
    (COALESCE(r.version, 0) >= 3) AS es_v3,
    r.rm_validado,
    r.rm_fch_rm,
    r.rm_cli_id,
    r.rm_cen_id,
    COALESCE(v2.cnt_v2, 0) AS protocolos_principales_v2,
    COALESCE(v3.cnt_v3, 0) AS protocolos_principales_v3,
    COALESCE(m.num_manuales, 0) AS num_manuales,
    m.nombres_manuales,
    CASE
        WHEN COALESCE(r.version, 0) < 3
             AND COALESCE(v2.cnt_v2, 0) = 0
             AND COALESCE(m.num_manuales, 0) > 0
            THEN 'A_v2_sin_pruebas_con_manual'
        WHEN COALESCE(r.version, 0) >= 3
             AND COALESCE(v3.cnt_v3, 0) = 0
             AND COALESCE(m.num_manuales, 0) > 0
            THEN 'B_v3_solo_basico_manual'
    END AS patron_bug
FROM vig_salud.inf_rm r
LEFT JOIN (
    SELECT p.rm_id, COUNT(DISTINCT p.pro_id) AS cnt_v2
    FROM vig_salud.vig_inf_pruebas p
    WHERE p.pro_id <> 61
    GROUP BY p.rm_id
) v2 ON v2.rm_id = r.rm_id
LEFT JOIN (
    SELECT ip.rm_id, COUNT(DISTINCT ip.protocolo_id) AS cnt_v3
    FROM vig_salud.inf3_rm_protocolos ip
    INNER JOIN vig_salud.pro_protocolos pp ON pp.id = ip.protocolo_id
    WHERE ip.borrado IS NULL
      AND pp.activo = 1
      AND ip.protocolo_id <> 21
    GROUP BY ip.rm_id
) v3 ON v3.rm_id = r.rm_id
LEFT JOIN (
    SELECT
        ip.rm_id,
        COUNT(*) AS num_manuales,
        STRING_AGG(DISTINCT COALESCE(i18n.denominacion, pp.denominacion), ', ') AS nombres_manuales
    FROM vig_salud.inf3_rm_protocolos ip
    INNER JOIN vig_salud.pro_protocolos pp ON pp.id = ip.protocolo_id
    LEFT JOIN vig_salud.pro_protocolos_i18n i18n
           ON i18n.item_id = pp.id AND i18n.idioma_cod = 'es'
    WHERE ip.borrado IS NULL
      AND pp.activo = 1
      AND ip.manual = 1
    GROUP BY ip.rm_id
) m ON m.rm_id = r.rm_id
WHERE r.rm_validado = 1
  AND (
        (COALESCE(r.version, 0) < 3
         AND COALESCE(v2.cnt_v2, 0) = 0
         AND COALESCE(m.num_manuales, 0) > 0)
     OR (COALESCE(r.version, 0) >= 3
         AND COALESCE(v3.cnt_v3, 0) = 0
         AND COALESCE(m.num_manuales, 0) > 0)
      )
ORDER BY r.rm_fch_rm DESC NULLS LAST
LIMIT 50;
