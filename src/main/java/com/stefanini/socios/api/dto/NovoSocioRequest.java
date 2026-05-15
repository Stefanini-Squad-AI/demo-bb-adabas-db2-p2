package com.stefanini.socios.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record NovoSocioRequest(
        @NotNull @Min(1) @Max(999999999L) Long numbSocioPrincipal,
        @NotBlank @Size(max = 40) String nomeSocioPrincipal,
        @NotNull @Min(1) @Max(2) Integer catgSocio,
        @NotNull @Min(1) @Max(31) Integer diaVencimento,
        @Size(max = 500) String obsvSocio) {}
