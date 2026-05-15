package com.stefanini.socios.repository;

import com.stefanini.socios.api.dto.SocioResponse;
import com.stefanini.socios.api.dto.SocioResponse.PeriodoPagamentoResponse;
import java.sql.Date;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

@Repository
public class SocioRepository {

    private final JdbcTemplate jdbc;

    public SocioRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public boolean existsByRg(long numbSocioPrincipal) {
        return Boolean.TRUE.equals(jdbc.query(
                "SELECT 1 FROM socio WHERE numb_socio_principal = ? LIMIT 1",
                rs -> {
                    if (!rs.next()) {
                        return false;
                    }
                    return true;
                },
                numbSocioPrincipal));
    }

    public Optional<SocioResponse> findByRg(long numbSocioPrincipal) {
        List<SocioResponse> socios = jdbc.query(
                """
                SELECT numb_socio_principal, nome_socio_principal, data_cadastro, catg_socio,
                       indi_divida, data_baixa, hora_baixa, obsv_socio
                FROM socio WHERE numb_socio_principal = ?
                """,
                socioHeaderMapper(),
                numbSocioPrincipal);
        if (socios.isEmpty()) {
            return Optional.empty();
        }
        List<PeriodoPagamentoResponse> periodos = jdbc.query(
                """
                SELECT periodo_index, data_vencimento, valr_mensalidade, pagamento_ok
                FROM socio_periodo_pagamento
                WHERE numb_socio_principal = ?
                ORDER BY periodo_index
                """,
                (rs, rowNum) -> new PeriodoPagamentoResponse(
                        rs.getInt("periodo_index"),
                        rs.getObject("data_vencimento", LocalDate.class),
                        rs.getBigDecimal("valr_mensalidade"),
                        rs.getBoolean("pagamento_ok")),
                numbSocioPrincipal);
        SocioResponse base = socios.get(0);
        return Optional.of(new SocioResponse(
                base.numbSocioPrincipal(),
                base.nomeSocioPrincipal(),
                base.dataCadastro(),
                base.catgSocio(),
                base.indiDivida(),
                base.dataBaixa(),
                base.horaBaixa(),
                base.obsvSocio(),
                periodos));
    }

    public void insertSocioComPeriodos(
            long numbSocioPrincipal,
            String nome,
            LocalDate dataCadastro,
            int catgSocio,
            String obsv,
            List<PeriodoPagamentoResponse> periodos) {
        jdbc.update(
                """
                INSERT INTO socio (numb_socio_principal, nome_socio_principal, data_cadastro, catg_socio,
                    indi_divida, data_baixa, hora_baixa, obsv_socio)
                VALUES (?, ?, ?, ?, NULL, NULL, NULL, ?)
                """,
                numbSocioPrincipal,
                nome,
                Date.valueOf(dataCadastro),
                catgSocio,
                obsv);
        for (PeriodoPagamentoResponse p : periodos) {
            jdbc.update(
                    """
                    INSERT INTO socio_periodo_pagamento
                    (numb_socio_principal, periodo_index, data_vencimento, valr_mensalidade, pagamento_ok)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    numbSocioPrincipal,
                    p.periodoIndex(),
                    Date.valueOf(p.dataVencimento()),
                    p.valrMensalidade(),
                    p.pagamentoOk());
        }
    }

    private static RowMapper<SocioResponse> socioHeaderMapper() {
        return (ResultSet rs, int rowNum) -> new SocioResponse(
                rs.getLong("numb_socio_principal"),
                rs.getString("nome_socio_principal"),
                rs.getObject("data_cadastro", LocalDate.class),
                rs.getInt("catg_socio"),
                (Integer) rs.getObject("indi_divida"),
                rs.getObject("data_baixa", LocalDate.class),
                rs.getString("hora_baixa"),
                rs.getString("obsv_socio"),
                List.of());
    }
}
