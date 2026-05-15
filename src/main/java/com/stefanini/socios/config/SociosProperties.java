package com.stefanini.socios.config;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "socios")
public class SociosProperties {

    private Map<String, BigDecimal> mensalidadePorCategoria = new HashMap<>();

    public Map<String, BigDecimal> getMensalidadePorCategoria() {
        return mensalidadePorCategoria;
    }

    public void setMensalidadePorCategoria(Map<String, BigDecimal> mensalidadePorCategoria) {
        this.mensalidadePorCategoria = mensalidadePorCategoria;
    }
}
