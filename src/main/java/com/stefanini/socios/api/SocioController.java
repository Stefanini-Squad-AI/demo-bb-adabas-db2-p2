package com.stefanini.socios.api;

import com.stefanini.socios.api.dto.NovoSocioRequest;
import com.stefanini.socios.api.dto.SocioResponse;
import com.stefanini.socios.service.SocioService;
import jakarta.validation.Valid;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/socios")
public class SocioController {

    private final SocioService socioService;

    public SocioController(SocioService socioService) {
        this.socioService = socioService;
    }

    /**
     * Equivalent to FIND SOCIO WITH NUMB-SOCIO-PRINCIPAL EQ #RG-CONSULTA when record exists.
     */
    @GetMapping("/{numbSocioPrincipal}")
    public ResponseEntity<SocioResponse> get(@PathVariable long numbSocioPrincipal) {
        return socioService
                .consultar(numbSocioPrincipal)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * Equivalent to PERFORM INCLUI-SOCIO + STORE when FIND returns no records.
     */
    @PostMapping
    public ResponseEntity<?> post(@Valid @RequestBody NovoSocioRequest body) {
        SocioResponse created = socioService.registrar(body);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * Mirrors map flow: consulta primeiro; se não existir, cliente pode POST com mesmo RG.
     */
    @GetMapping("/{numbSocioPrincipal}/status")
    public ResponseEntity<Map<String, Object>> status(@PathVariable long numbSocioPrincipal) {
        boolean existe = socioService.consultar(numbSocioPrincipal).isPresent();
        if (existe) {
            return ResponseEntity.ok(Map.of("cadastrado", true, "mensagem", "Sócio já cadastrado."));
        }
        return ResponseEntity.ok(Map.of("cadastrado", false, "mensagem", "Prosseguir com inclusão (POST /api/socios)."));
    }
}
