package com.stefanini.socios.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record SocioResponse(
        long numbSocioPrincipal,
        String nomeSocioPrincipal,
        LocalDate dataCadastro,
        int catgSocio,
        Integer indiDivida,
        LocalDate dataBaixa,
        String horaBaixa,
        String obsvSocio,
        List<PeriodoPagamentoResponse> periodos) {

    public record PeriodoPagamentoResponse(
            int periodoIndex, LocalDate dataVencimento, BigDecimal valrMensalidade, boolean pagamentoOk) {}
}
