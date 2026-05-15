package com.stefanini.socios.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Replicates Natural date loop in STFPCS00-P2 (DATX YYYYMMDD + #DIA-VENCIAMENTO, then ADD 1 TO #MES per period).
 */
public final class PeriodoVencimentoCalculator {

    private PeriodoVencimentoCalculator() {}

    public static List<LocalDate> dozeVencimentos(LocalDate hoje, int diaVencimento) {
        List<LocalDate> datas = new ArrayList<>(12);
        LocalDate primeiro = primeiroVencimentoNoMes(hoje, diaVencimento);
        datas.add(primeiro);
        LocalDate cursor = primeiro;
        for (int i = 2; i <= 12; i++) {
            cursor = cursor.plusMonths(1);
            cursor = ajustaDiaDoMes(cursor, diaVencimento);
            datas.add(cursor);
        }
        return datas;
    }

    private static LocalDate primeiroVencimentoNoMes(LocalDate hoje, int diaVencimento) {
        return ajustaDiaDoMes(hoje, diaVencimento);
    }

    private static LocalDate ajustaDiaDoMes(LocalDate referencia, int diaVencimento) {
        int dia = Math.min(diaVencimento, referencia.lengthOfMonth());
        return referencia.withDayOfMonth(dia);
    }
}
