"""
Résolution d'EDOs de type `` \\frac{dY}{dt}(t) = F(t,Y(t))`` avec les
conditions initiales ``Y(t_0) = Y_0`` à l'aide de la méthode d'Euler explicite
jusqu'au temps ``t_f`` avec pas constant ``h``:

``Y_{n+1} = Y_{n} + h F(t_n,Y_n)``

# Syntaxe
```julia
(t,Y) = euler(fct , tspan , Y0 , nbpas)
```

# Entrée
    1.  fct     -   Fonction décrivant le système de N EDOs
    2.  tspan   -   (Array{Float,1}) Vecteur contenant le temps initial et final (tspan=[t0,tf])
    3.  Y0      -   (Array{Float,1}) Vecteur contenant les N conditions initiales
    4.  nbpas   -   (Integer) Nombre de pas de temps

# Sortie
    1.  temps   -   (Array{Float,1}) Vecteur contenant les pas de temps
    2.  Y       -   (Array{Float,2}) Matrice de dimension (nbpas+1) x N contenant les approximations

# Exemples d'appel
```julia
function my_edo(t,z)
    f = zeros(length(z))
    f[1] = z[2]
    f[2] = -z[1]
    return f
end
(t,y)   =   euler(my_edo , [0;10] , [1;0] , 1000)
```
```julia
(t,y)   =   euler((t,y) -> cos(t) , [0;2] , 1 , 1000)
```
```julia
(t,y)   =   euler((t,y) -> [y[2];-y[1]] , [0;10] , [1;0] , 1000)
```
"""
function euler(fct::Function, tspan::AbstractVector{T}, Y0::AbstractVector{T} , nbpas::Integer) where {T<:AbstractFloat}

     # Vérification des arguments d'entrée
     if length(tspan) != 2
         error("Le vecteur tspan doit contenir 2 composantes, [t0 , tf]")
     elseif nbpas<=0
         error(string("L'argument nbpas=$nbpas n'est pas valide. ",
                          "Cet argument doit être un entier > 0."))
     end

     try
         fct(tspan[1],Y0)
     catch y
         if isa(y,BoundsError)
             error("Le nombre de composantes de Y0 et f ne concorde pas")
         else
             error(y)
         end
     end

     if ~isa(fct(tspan[1],Y0),T) && ~isa(fct(tspan[1],Y0),Array{T,1})
         error("La fonction f ne retourne pas un vecteur de type float")
     elseif (length(Y0) != length(fct(tspan[1],Y0)))
         error("Le nombre de composantes de Y0 et f ne concorde pas")
     end

     N       =   length(Y0)
     Y       =   zeros(T,N,nbpas+1)
     Y[:,1]  .=  Y0
     temps   =   LinRange{T}(tspan[1], tspan[2] , nbpas+1)
     h       =   temps[2] - temps[1]

     for t=1:nbpas
         Y[:,t+1] .= view(Y,:,t) .+ h .* fct(temps[t], view(Y,:,t))
     end

     return  temps , transpose(Y)

end

@inline euler(fct::Function, tspan::AbstractVector{<:Real}, Y0::AbstractVector{<:Real}, nbpas::Integer) = euler(fct, Float64.(tspan), Float64.(Y0), nbpas)

@inline euler(fct::Function , tspan::AbstractVector{<:Real}, Y0::Real, nbpas::Integer) = euler(fct, Float64.(tspan), [Float64(Y0)], nbpas)
