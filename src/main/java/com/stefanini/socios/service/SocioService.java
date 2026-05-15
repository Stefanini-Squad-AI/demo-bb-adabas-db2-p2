package com.stefanini.socios.service;

import com.stefanini.socios.api.dto.NovoSocioRequest;
import com.stefanini.socios.api.dto.SocioResponse;
import com.stefanini.socios.api.dto.SocioResponse.PeriodoPagamentoResponse;
import com.stefanini.socios.config.SociosProperties;
import com.stefanini.socios.domain.PeriodoVencimentoCalculator;
import com.stefanini.socios.repository.SocioRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SocioService {

    private static final Set<Integer> DIAS_VENCIMENTO_VALIDOS = Set.of(1, 5, 15, 20, 25);

    private final SocioRepository repository;
    private final SociosProperties properties;

    public SocioService(SocioRepository repository, SociosProperties properties) {
        this.repository = repository;
        this.properties = properties;
    }

    public Optional<SocioResponse> consultar(long numbSocioPrincipal) {
        return repository.findByRg(numbSocioPrincipal);
    }

    @Transactional
    public SocioResponse registrar(NovoSocioRequest req) {
        long rg = req.numbSocioPrincipal();
        if (repository.existsByRg(rg)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Sócio já cadastrado.");
        }
        int catg = req.catgSocio();
        if (catg != 1 && catg != 2) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Categoria inválida.");
        }
        int dia = req.diaVencimento();
        if (!DIAS_VENCIMENTO_VALIDOS.contains(dia)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Dia do vencimento inválido.");
        }

        BigDecimal mensalidade = properties
                .getMensalidadePorCategoria()
                .get(Integer.toString(catg));
        if (mensalidade == null) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Mensalidade não configurada para a categoria " + catg + " (substituto de VERVALOR).");
        }

        LocalDate hoje = LocalDate.now();
        List<LocalDate> vencimentos = PeriodoVencimentoCalculator.dozeVencimentos(hoje, dia);
        List<PeriodoPagamentoResponse> periodos = new ArrayList<>();
        for (int i = 0; i < 12; i++) {
            boolean ok = i == 0;
            periodos.add(new PeriodoPagamentoResponse(i + 1, vencimentos.get(i), mensalidade, ok));
        }

        String obsv = req.obsvSocio();
        if (obsv == null || obsv.isBlank()) {
            obsv = "Novo sócio";
        }

        repository.insertSocioComPeriodos(rg, req.nomeSocioPrincipal().trim(), hoje, catg, obsv, periodos);

        return repository
                .findByRg(rg)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.INTERNAL_SERVER_ERROR, "Falha ao carregar sócio recém-criado."));
    }
}
