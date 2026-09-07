package util;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DbUtils — Helper JDBC para usar desde features de Karate.
 *
 * Normaliza tipos JDBC (ej: BigDecimal -> Double) para compatibilidad
 * perfecta con números JSON en Karate DSL.
 */
public class DbUtils {

    private final JdbcTemplate jdbc;

    public DbUtils(Map<String, Object> config) {
        DriverManagerDataSource ds = new DriverManagerDataSource();
        ds.setDriverClassName("org.postgresql.Driver");
        ds.setUrl((String) config.get("url"));
        ds.setUsername((String) config.get("username"));
        ds.setPassword((String) config.get("password"));
        this.jdbc = new JdbcTemplate(ds);
    }

    private Map<String, Object> cleanRow(Map<String, Object> row) {
        if (row == null) return null;
        Map<String, Object> clean = new LinkedHashMap<>();
        for (Map.Entry<String, Object> entry : row.entrySet()) {
            Object val = entry.getValue();
            if (val instanceof BigDecimal) {
                clean.put(entry.getKey(), ((BigDecimal) val).doubleValue());
            } else {
                clean.put(entry.getKey(), val);
            }
        }
        return clean;
    }

    private List<Map<String, Object>> cleanRows(List<Map<String, Object>> rows) {
        List<Map<String, Object>> cleaned = new ArrayList<>(rows.size());
        for (Map<String, Object> row : rows) {
            cleaned.add(cleanRow(row));
        }
        return cleaned;
    }

    public List<Map<String, Object>> query(String sql) {
        return cleanRows(jdbc.queryForList(sql));
    }

    public List<Map<String, Object>> queryWithParams(String sql, Object... params) {
        return cleanRows(jdbc.queryForList(sql, params));
    }

    public Map<String, Object> queryOne(String sql) {
        List<Map<String, Object>> rows = jdbc.queryForList(sql);
        return rows.isEmpty() ? null : cleanRow(rows.get(0));
    }

    public int count(String sql) {
        Integer result = jdbc.queryForObject(sql, Integer.class);
        return result != null ? result : 0;
    }

    public int execute(String sql) {
        return jdbc.update(sql);
    }

    public int executeWithParams(String sql, Object... params) {
        return jdbc.update(sql, params);
    }
}
