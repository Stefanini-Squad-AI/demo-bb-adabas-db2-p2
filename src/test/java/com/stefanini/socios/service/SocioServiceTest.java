package com.stefanini.socios.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.stefanini.socios.api.dto.NovoSocioRequest;
import com.stefanini.socios.config.SociosProperties;
import com.stefanini.socios.repository.SocioRepository;
import java.math.BigDecimal;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class SocioServiceTest {

    @Mock
    private SocioRepository repository;

    private SocioService service;

    @BeforeEach
    void setUp() {
        SociosProperties props = new SociosProperties();
        props.setMensalidadePorCategoria(Map.of("1", new BigDecimal("99.99"), "2", new BigDecimal("49.50")));
        service = new SocioService(repository, props);
    }

    @Test
    void registrar_rejeitaDuplicata() {
        when(repository.existsByRg(123L)).thenReturn(true);
        assertThatThrownBy(() -> service.registrar(new NovoSocioRequest(
                        123L, "Nome", 1, 15, null)))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(ex -> assertThat(((ResponseStatusException) ex).getStatusCode())
                        .isEqualTo(HttpStatus.CONFLICT));
        verify(repository, never()).insertSocioComPeriodos(anyLong(), anyString(), any(), anyInt(), anyString(), anyList());
    }
}
