package com.stefanini.socios.domain;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

class PeriodoVencimentoCalculatorTest {

    @Test
    void dozeVencimentos_avancaMesAMes() {
        LocalDate hoje = LocalDate.of(2026, 5, 15);
        List<LocalDate> datas = PeriodoVencimentoCalculator.dozeVencimentos(hoje, 5);
        assertThat(datas).hasSize(12);
        assertThat(datas.get(0)).isEqualTo(LocalDate.of(2026, 5, 5));
        assertThat(datas.get(1)).isEqualTo(LocalDate.of(2026, 6, 5));
        assertThat(datas.get(11)).isEqualTo(LocalDate.of(2027, 4, 5));
    }
}
