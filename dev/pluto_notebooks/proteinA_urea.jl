### A Pluto.jl notebook ###
# v0.19.47

using Markdown
using InteractiveUtils

# ╔═╡ 96e27383-8c0b-4b95-b7fb-80bb97f390bb
import Pkg

# ╔═╡ 68f2fa1e-cba9-4da9-ae13-9d0828c2bd15
using CSV

# ╔═╡ dff61cee-c2c4-41aa-8fc1-fbac08a67beb
using Trapz

# ╔═╡ 3bac1a1e-9bb1-4125-9b58-2bd43d959fa9
using MolSimToolkit

# ╔═╡ b622c2a7-6e74-4b49-9e11-ad5b78508cd9
using DataFrames

# ╔═╡ 04a3248a-9705-4c0f-bb44-5647fff61e81
using Unitful

# ╔═╡ 3b7d6a34-d8a3-4ad5-bf04-6fc2ccfe6bb3
using Plots

# ╔═╡ d5de2209-1980-481a-a7bd-9ed1d4ea7757
using ColorSchemes

# ╔═╡ d44450c2-fff7-4c4d-8231-57baab6cc404
using LaTeXStrings

# ╔═╡ 229dec7b-d92c-4c74-8a9f-fe21c3b0fb0d
using EasyFit

# ╔═╡ f8129573-5a9f-4989-a9f4-16659ef9b9af
begin
    using PlutoUI
    TableOfContents()
end

# ╔═╡ 6edcdced-5fb5-41f4-a741-27c98dcbd1b4
md"# BdpA transfer free energy to urea"

# ╔═╡ ea84b823-a39d-455c-be84-fe9dce10c4d8
md"## BdpA in urea"

# ╔═╡ 7ee8f5de-12d7-4dac-8933-a319ee6ed77a
md"""
In [Lin & Timasheff, Biochemistry, 1994](https://pubs.acs.org/doi/10.1021/bi00208a021), the following equation (Equation 5 of the article) is used to obtain the variation of the chemical potential of the proteins as a function of the concentration, $m_3$, of the cosolvent:

$$\left(\frac{\partial\mu_2}{\partial m_3}\right)_{T,P,m_2} = 
-\left(\frac{\partial g_3}{\partial g_2}\right)_{T,P,\mu_3}
\left(\frac{RTM_2}{M_3}\right)
\left(\frac{1}{m_3}+\frac{\partial\ln \gamma_3}{\partial m_3}\right)$$

"""

# ╔═╡ e5aedbda-67e9-465e-91f1-10125bee8dc0
md"where, in the case of urea (species 3) and BdpA (solute, species 2) we have:"

# ╔═╡ f9e5b61b-330d-40ee-8667-7af9012a6f62
M3 = 60.06u"g/mol"

# ╔═╡ 5fd21ecd-80ab-4d7f-ad64-cb33a399c289
M2 = 6768.46u"g/mol"

# ╔═╡ ca23c373-02c2-4e50-8c48-0cb2477eed59
md"""
and $\partial g_3\partial g_2$ are the preferential interaction parameters and $\gamma_3$ is the activity coefficient of the cosolvent. Here, the preferential interaction parameters are obtained from the simulations, and the activity coefficients are obtained from the reported experimental data (see below).
"""

# ╔═╡ deaa5dbb-e0db-4f26-b4b4-af2c72bec167
md"""
### States considered

Here, three-fold states are considered, from the set obtained in the simulations: the native state and two denatured states:

- Native state: Most representative structure of the $N^{B0}_{84}$ basin.
- First denatured state: Most reprensentative structure of the $U^{B1}_{63}$ basin.
- Second denatured state: Most representative structure of the $U^{B11}_{37}$ basin.

From here on, these states will be referred to as **N**, **U1**, and **U2**.
"""

# ╔═╡ fb3f40bf-4b4b-4992-9eb7-667d8b12fe64
md"The molalities of urea in the bulk phase of each simulated concentration are:"

# ╔═╡ b2529e4f-a312-4adc-adf2-3f1f70a7b35f
md"### Simulated preferential interactions:"

# ╔═╡ bb81d137-effe-4107-a61b-fd529cff8421
md"The preferential interaction parameters of BdpA in urea, for the N, U1, and U2 states, are (converted from mol/mol to g/g):"

# ╔═╡ 813427fb-7d88-44f3-b118-2d5b94031a50
∂g₃∂g₂ = DataFrame(
	"N" => [ 0.7183619897764626, 1.1190988702939448, 1.8736743932634519, 2.6228085355885495, 2.9834878715419766, 4.067502417416314, 5.0505944986454265 ] / (M2/M3),
	"U1" => [ 0.48406978878065254, 1.0003944967898128, 1.5640774978350973, 1.910211690464814, 2.4824953492277486, 3.7701767350550695, 4.630159167486121 ] / (M2/M3),
	"U2" => [ 0.689152777286788, 1.42250560321966, 2.091784228969367, 2.6881984234814795, 3.391392504415016, 4.961542591684065, 6.244468153147672 ] / (M2/M3),
)

# ╔═╡ 4b30017b-ef13-45f1-8303-13a87b154841
md"Corresponding to the folowing plot:"

# ╔═╡ b188c630-5beb-40e3-9b92-260b385fc295
md"### The transfer free energy"

# ╔═╡ e3e99ddc-36ea-4b53-bb07-753670a013db
md"Using the gas constant in kcal/(K mol), and the temperature in K:"

# ╔═╡ 12fa8a68-6fed-4d1f-ac71-864ca078c5a7
R = 1.9872036e-3u"kcal/(K*mol)"

# ╔═╡ 6a7e36c3-f441-46e5-8070-906ee366260d
T = 298u"K"

# ╔═╡ e8345099-906f-4965-bd3b-1d3f80eb2250
md"We can define Eq. 5 of the article (written above), as a function of the preferential interactions, molar mass of the cossolvent, and ∂lnγ₃∂m₃:"

# ╔═╡ 53c3949d-6e77-4606-8882-db4a798eed2c
md"Applying this equation to the data obtained from the simulations, we get:"

# ╔═╡ da89afa4-43bc-4906-b01b-9f6ec455f229
md"""
Now we can plot those values as function of the concentration of urea:
"""

# ╔═╡ 681ecbaa-1370-468a-b3d8-7f01b373b3f6
md"""
The shaded areas are, qualitatively, the transfer free energy of each state up to each concentration.

Integrating these curves provides a qualitative measure of the free energy of transfer in each case:
"""

# ╔═╡ d904f54e-e284-46bb-b7a6-9fae79e01300
#Δμ₂_N = trapz(simulated_m₃[!,"N"],∂μ₂∂m₃_sim[!,"N"])	

# ╔═╡ 5edbb407-3655-45f6-aa9b-8fae111b2eee
#Δμ₂_U1 = trapz(simulated_m₃[!,"U1"],∂μ₂∂m₃_sim[!,"U1"])

# ╔═╡ 62629866-b03e-4a61-b3fa-b6a12e3aa7c8
#Δμ₂_U2 = trapz(simulated_m₃[!,"U2"],∂μ₂∂m₃_sim[!,"U2"])

# ╔═╡ 4f68effa-b334-4c85-b462-d5c6554e7ea3
md"""
The results imply that the U2 denatured state is slightly more favorably transferred to a 0.5 mol/L aqueous urea solution than the native state. In contrast, the native state is slightly more stabilized than the U1 unfolded state in all concentrations. It is probably associated with the structural similarity of the U1 unfolded state to the native. 

The difference increases with increasing urea concentration. At higher urea concentrations the integrals associated with the U2 denatured state become progressively more negative, thus this state is stabilized relative to the native and U1 unfolded state upon transfer to a urea solution.
"""

# ╔═╡ 3b976cdf-09d2-4c43-881c-c1eadb4ea238
md"## Aqueous solutions of urea: experimental data"

# ╔═╡ 19208b6e-7039-11ef-2685-c9fd57102877
md"""
In [Lin & Timasheff, Biochemistry, 1994](https://pubs.acs.org/doi/10.1021/bi00208a021), the activity coefficients ($\gamma_3$) of urea in aqueous solutions and the corresponding densities are provided. The data provided is that of $\gamma_3$ as a function of the concentration $m_3$ (in mol/kg):

"""

# ╔═╡ 77c25151-8673-4ec1-9687-80f1fceb4e5c
md"### Properties of aqueous solutions of urea"

# ╔═╡ 6f3ec99b-15b1-4014-b146-09e29864382c
md"Experimental data for urea aqueous solutions (at 25$^\circ$C):"

# ╔═╡ 8293f49a-57a1-49b5-a2da-95a43b4cd097
urea_data = DataFrame(
	:m₃ => [0.0, 0.51, 1.05, 2.20]u"mol/kg",
	:γ₃ => [1.0, 0.960, 0.924, 0.859],
	:ρ₀ => [0.9970, 1.0084, 1.0160, 1.0298]u"g/mL",
)

# ╔═╡ 1ca88373-114c-464d-aaac-9f3b25893820
md"""
The data above is used to compute the $(\partial\ln\gamma_3/\partial m_3)$ quantity. For that we need to create first a plot:
"""

# ╔═╡ 90ad306d-163e-4fb3-a00e-6b86c32900f9
begin
p0 = scatter(MolSimStyle,
	urea_data[!,:m₃], log.(urea_data[!,:γ₃]),
	xlabel=L"m_3", ylabel=L"\ln(\gamma_3)", label="urea", color=:blue,
)
plot!(p0,
	urea_data[!,:m₃], log.(urea_data[!,:γ₃]); 
	label=nothing, color=:blue,
)
plot!(p0, size=(400,300))
p0
end

# ╔═╡ 357f0851-8ba2-4dbe-9c49-e5bd15f3f93b
md"""
The shape of the plot suggests that a quadratic fit will capture precisely the trend:
"""

# ╔═╡ e30af672-9c42-4d19-8b5b-dbf1dc0d9680
urea_fit = fitquadratic(urea_data[!,:m₃],log.(urea_data[!,:γ₃]))

# ╔═╡ c08a180a-e8cf-4f02-9451-1d40fb96a653
md"The derivative of the logarithmic of the activity coefficient as a function of the molality is, then, the derivative of the above quadratic fit:"

# ╔═╡ f9ec92d4-4ab4-4a9c-b240-7fe5d28e0018
∂lnγ₃∂m₃(m₃) = 2 * urea_fit.a * m₃ + urea_fit.b

# ╔═╡ a8fc4634-018b-4633-85b3-fb0ba639a49a
∂μ₂∂m₃(∂g₃∂g₂, m₃, M2, M3) = -(∂g₃∂g₂) * (R * T * M2 / M3) * (1/m₃ + ∂lnγ₃∂m₃(m₃))

# ╔═╡ 24202850-e8fa-4172-91f9-d31ad67e0d3e
md"""
Which can be computed for the concentrations given in Table 2 of the article, and do not agree quantitatively, but follow the same trend:
"""

# ╔═╡ c18b8343-1911-4864-918f-2083637524d7
urea_data[:, :∂lnγ₃∂m₃] = ∂lnγ₃∂m₃.(urea_data[!,:m₃])

# ╔═╡ 72b526a6-6e22-40a1-ac76-8f766681ff87
urea_data

# ╔═╡ 7027914f-2195-472e-968e-c5e587b84dba
md"We also obtain an expression for the density as a function of the concentration, in mol/L:"

# ╔═╡ c1940fde-3164-40e7-8679-c16e872c38b8
begin
	# convert concentration to mol/L
	c3 = uconvert.(u"mol/L", urea_data[!,:m₃] .* urea_data[!,:ρ₀])
	p1 = scatter(MolSimStyle, 
		c3, urea_data[!,:ρ₀],
		label=:none,
	    xlabel=L"c_3", ylabel=L"\rho_0", color=:blue,
	)
	density_fit = fitquadratic(c3, urea_data[!,:ρ₀])
	plot!(p1, density_fit.x, density_fit.y, label=:none, color=:blue)
	plot!(p1, size=(400,300))
	p1
end

# ╔═╡ b18ed62a-9b12-467d-b289-7720a45817d3
md"Where the fit is:"

# ╔═╡ d4efcd42-14e6-46f0-85b7-0c917b09e7a1
density_fit

# ╔═╡ dd52ea0b-db95-4d07-8d12-cea548508033
md"### Converting simulated concentrations:"

# ╔═╡ 04514294-71e6-4185-b5a0-35eb09066e6f
md"For the N and U states, the obtained bulk concentrations of urea are obtained from the simulations in mol/L:"


# ╔═╡ 14f768ba-30e1-4fbb-ba80-70065873a830
c = DataFrame(
        "N" => [ 0.09716985987666786, 0.19593025658410618, 0.2936661828224171, 0.399307543532975, 0.5017441561880707, 0.7548138031687455, 1.0153120601684178 ]u"mol/L",
	"U1" => [ 0.10008328157506186, 0.20567616748176043, 0.300151718907769, 0.4034765634297125, 0.500877007568447, 0.7593790833710268, 1.0230281972305728 ]u"mol/L",
	"U2" => [ 0.09799551984651836, 0.19511662036002622, 0.302804132189018, 0.3983164080671409, 0.5025173862339127, 0.7631637004388037, 1.0215719381511 ]u"mol/L"
)

# ╔═╡ dbcd0df8-c2ee-4ba0-bcb5-75fe898b6f0f
md"The densities corresponding to these concentrations, according to the experimental densities, are:"

# ╔═╡ 5a27e717-91ff-4d60-9e57-d32330121090
ρ = DataFrame(
	"N" => density_fit.(c[!,"N"]),
	"U1" => density_fit.(c[!,"U1"]),
	"U2" => density_fit.(c[!,"U2"]),
)

# ╔═╡ 23095d73-0957-450e-8537-72431506fd4d
simulated_m₃ = DataFrame(
	"N" => uconvert.(u"mol/kg", c[!,"N"] ./ ρ[!,"N"]),
	"U1" => uconvert.(u"mol/kg", c[!,"U1"] ./ ρ[!,"U1"]),
	"U2" => uconvert.(u"mol/kg", c[!,"U2"] ./ ρ[!,"U2"]),
)

# ╔═╡ 9fa845c7-dd1e-40ea-9cd9-6126783aad94
∂μ₂∂m₃_sim = DataFrame(
    "N" => ∂μ₂∂m₃.(∂g₃∂g₂[!,"N"], simulated_m₃[!,"N"], M2, M3),
	"U1" => ∂μ₂∂m₃.(∂g₃∂g₂[!,"U1"], simulated_m₃[!,"U1"], M2, M3),
	"U2" => ∂μ₂∂m₃.(∂g₃∂g₂[!,"U2"], simulated_m₃[!,"U2"], M2, M3),
)

# ╔═╡ 025fed74-93a2-4bb9-96b6-9e4c1a00c75d
begin
	p2 = plot()
	states = ["N", "U1", "U2"]
	labels = [ L"{\mathrm{N^{B0}_{84}}}", L"{\mathrm{U^{B1}_{63}}}", L"{\mathrm{U^{B11}_{37}}}" ]
    colors = [ get(ColorSchemes.okabe_ito,(12)/12), get(ColorSchemes.okabe_ito,(11)/12), get(ColorSchemes.okabe_ito,(1)/12)]
	for i in eachindex(states)
		s = states[i]
		c = colors[i]
	    p2 = scatter!(MolSimStyle,
	    	simulated_m₃[!,s], ∂μ₂∂m₃_sim[!,s], label=labels[i],
	 		xlabel=L"m_3", ylabel=L"\partial\mu_2\partial m_3",
			color=c, dpi=300
		)
		plot!(p2, 
			simulated_m₃[!,s], ∂μ₂∂m₃_sim[!,s], label=nothing,
			fillrange=(0:0.5), fc=c, alpha=0.1, dpi=300
		)
	end
	plot!(p2, size=(400,300))
	#savefig("proteinA_UREA_TFE.pdf")
end

# ╔═╡ 4d8bfae0-2eda-462b-a9ec-c0082097305d
begin
	p3 = scatter(MolSimStyle,
		simulated_m₃[!,"N"], ∂g₃∂g₂[!,"N"], label=L"{\mathrm{N^{B0}_{84}}}",
		xlabel=L"m_3", ylabel=L"\partial g_2\partial g_3 \mathrm{(g/g)}",
		color=colors[1]
	)
	scatter!(p3,
		simulated_m₃[!,"U1"], ∂g₃∂g₂[!,"U1"], label=L"{\mathrm{U^{B1}_{63}}}",
		color=colors[2]

	)
	scatter!(p3,
		simulated_m₃[!,"U2"], ∂g₃∂g₂[!,"U2"], label=L"{\mathrm{U^{B11}_{37}}}",
		color=colors[3], dpi=300
	)
	plot!(p3, size=(400,300))
	#savefig("proteinA_UREA_Γ.pdf")
end

# ╔═╡ 5970ff0f-445f-4d27-8a54-56a7763c6e8c
let
	
# Arrays to store results
Δμ₂_N_values = []
Δμ₂_U1_values = []
Δμ₂_U2_values = []

# Compute and store Δμ₂_N
for i in 2:7
    Δμ₂_N = trapz(simulated_m₃[1:i, "N"], ∂μ₂∂m₃_sim[1:i, "N"])
    push!(Δμ₂_N_values, ustrip(Δμ₂_N))
end

# Compute and store Δμ₂_U1
for i in 2:7
    Δμ₂_U1 = trapz(simulated_m₃[1:i, "U1"], ∂μ₂∂m₃_sim[1:i, "U1"])
    push!(Δμ₂_U1_values, ustrip(Δμ₂_U1))
end

# Compute and store Δμ₂_U2
for i in 2:7
    Δμ₂_U2 = trapz(simulated_m₃[1:i, "U2"], ∂μ₂∂m₃_sim[1:i, "U2"])
    push!(Δμ₂_U2_values, ustrip(Δμ₂_U2))
end

# Create a DataFrame
df = DataFrame(
    Δμ₂_N = Δμ₂_N_values,
    Δμ₂_U1 = Δμ₂_U1_values,
    Δμ₂_U2 = Δμ₂_U2_values
)

# Save DataFrame to CSV
#CSV.write("./protein_a_urea_delta_mu_values.csv", df)

end

# ╔═╡ 6da7221d-55be-41c2-b74d-00e993d299f6
md"### Packages used"

# ╔═╡ 5275bb7b-944d-4c25-a46d-44bda09d07e1
Pkg.status()

# ╔═╡ 4aaa1252-1f0f-4dde-b87e-9669bb3ecccb
VERSION

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
EasyFit = "fde71243-0cda-4261-b7c7-4845bd106b21"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
MolSimToolkit = "054db54f-6694-444d-9bbb-e9ecdbfe77be"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Trapz = "592b5752-818d-11e9-1e9a-2b8ca4a44cd1"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[compat]
CSV = "~0.10.15"
ColorSchemes = "~3.26.0"
DataFrames = "~1.6.1"
EasyFit = "~0.6.6"
LaTeXStrings = "~1.3.1"
MolSimToolkit = "~1.19.0"
Plots = "~1.40.8"
PlutoUI = "~0.7.60"
Trapz = "~2.0.3"
Unitful = "~1.21.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "186e9edfd1ae945ccf31bd7e66457c37def820e8"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "50c3c56a52972d78e8be9fd135bfb91c9574c140"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.1.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "c5aeb516a84459e0318a02507d2261edad97eb75"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.7.1"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AtomsBase]]
deps = ["LinearAlgebra", "PeriodicTable", "Printf", "Requires", "StaticArrays", "Unitful", "UnitfulAtomic"]
git-tree-sha1 = "aab46de4a22e3619fe0167a18019b94a65033bd7"
uuid = "a963bdd2-2df7-4f54-a1ee-49d51e6be12a"
version = "0.4.2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "35abeca13bc0425cff9e59e229d971f5231323bf"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+3"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "deddd8725e5e1cc49ee205a1964256043720a6c3"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.15"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CellListMap]]
deps = ["Compat", "DocStringExtensions", "LinearAlgebra", "Parameters", "PrecompileTools", "ProgressMeter", "Random", "Setfield", "StaticArrays", "TestItems"]
git-tree-sha1 = "bc06e4443c9fe63ceb22b31b9a246cd0af51e7f0"
uuid = "69e1c6dd-3888-40e6-b3c8-31ac5f578864"
version = "0.9.6"

[[deps.Chemfiles]]
deps = ["Chemfiles_jll", "DocStringExtensions"]
git-tree-sha1 = "6951fe6a535a07041122a3a6860a63a7a83e081e"
uuid = "46823bd8-5fb3-5f92-9aa0-96921f3dd015"
version = "0.10.40"

[[deps.Chemfiles_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f3743181e30d87c23d9c8ebd493b77f43d8f1890"
uuid = "78a364fa-1a3c-552a-b4bb-8fa0f9c1fcca"
version = "0.10.4+0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "f36e5e8fdffcb5646ea5da81495a5a7566005127"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.3"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DSSP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "48a249fcd3cc9032191d08216e1acc2d5ca5a321"
uuid = "74334e00-59ce-546d-b517-81f3b7e1d491"
version = "4.4.0+1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "4b138e4643b577ccf355377c2bc70fa975af25de"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.115"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EasyFit]]
deps = ["LsqFit", "Parameters", "Statistics", "TestItems", "Unitful"]
git-tree-sha1 = "46097864204031cdf46d52f22cc8bf894c995cea"
uuid = "fde71243-0cda-4261-b7c7-4845bd106b21"
version = "0.6.8"

    [deps.EasyFit.extensions]
    SplineFitExt = "Interpolations"

    [deps.EasyFit.weakdeps]
    Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f42a5b1e20e009a43c3646635ed81a9fcaccb287"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.4+2"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays"]
git-tree-sha1 = "73d1214fec245096717847c62d389a5d2ac86504"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.22.0"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "21fac3c77d7b5a9fc03b0ec503aa1a6392c34d2b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.15.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "786e968a8d2fb167f2e4880baba62e0e26bd8e4e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "846f7026a9decf3679419122b49f8a1fdb48d2d5"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.16+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "424c8f76017e39fdfcdbb5935a8e6742244959e8"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "b90934c8cb33920a8dc66736471dc3961b42ec9f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "b1c2585431c382e3fe5805874bda6aea90a95de9"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.25"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "71b48d857e86bf7a1838c4736545699974ce79a2"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.9"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3447a92280ecaad1bd93d3fce3d408b6cfff8913"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.0+1"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78e0f4b5270c4ae09c7c5f78e77b904199038945"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.0+2"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "16e6ec700154e8004dba90b4aec376f68905d104"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+2"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dc4e8d10d4c6c11bf8d52dfd7213c09863c38cd5"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.51.0+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d841749621f4dcf0ddc26a27d1f6484dfc37659a"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.2+1"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "b404131d06f7886402758c9ce2214b636eb4d54a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9d630b7fb0be32eeb5e8da515f5e8a26deb457fe"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.2+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.LsqFit]]
deps = ["Distributions", "ForwardDiff", "LinearAlgebra", "NLSolversBase", "Printf", "StatsAPI"]
git-tree-sha1 = "40acc20cfb253cf061c1a2a2ea28de85235eeee1"
uuid = "2fda8390-95c7-5789-9bda-21331edee243"
version = "0.15.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MolSimToolkit]]
deps = ["AtomsBase", "CellListMap", "Chemfiles", "DocStringExtensions", "EasyFit", "LaTeXStrings", "LinearAlgebra", "OffsetArrays", "PDBTools", "ProgressMeter", "ProteinSecondaryStructures", "Reexport", "StaticArrays", "Statistics", "StatsBase", "TestItems"]
git-tree-sha1 = "c7072a3552b40f20d20c9bd56e8da0b0b527205d"
uuid = "054db54f-6694-444d-9bbb-e9ecdbfe77be"
version = "1.19.0"
weakdeps = ["Plots"]

    [deps.MolSimToolkit.extensions]
    Plotting = "Plots"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "5e1897147d1ff8d98883cda2be2187dcf57d8f0c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.15.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f58782a883ecbf9fb48dcd363f9ccd65f36c23a8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "418e63d434f5ca12b188bbb287dfbe10a5af1da4"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+1"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "12f1439c4f986bb868acda6ea33ebc78e19b95ad"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.7.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDBTools]]
deps = ["AtomsBase", "Dates", "Downloads", "Format", "InteractiveUtils", "LinearAlgebra", "OrderedCollections", "Parameters", "Printf", "StaticArrays", "TestItems"]
git-tree-sha1 = "ddc47124cc58e550c8b89a54afbaba7556c1e796"
uuid = "e29189f1-7114-4dbd-93d0-c5673a921a58"
version = "1.8.7"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ed6834e95bd326c52d5675b4181386dfbe885afb"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.55.5+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.PeriodicTable]]
deps = ["Base64", "Unitful"]
git-tree-sha1 = "238aa6298007565529f911b734e18addd56985e1"
uuid = "7b2266bf-644c-5ea3-82d8-af4bbd25a884"
version = "1.2.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "dae01f8c2e069a683d3a6e17bbae5070ab94786f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.9"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.ProteinSecondaryStructures]]
deps = ["DSSP_jll", "STRIDE_jll", "TestItems"]
git-tree-sha1 = "da7a6710aff45dfab7c4b7da921ef49aa1605364"
uuid = "c298f58b-271f-48cb-96ac-5442ca7c67d9"
version = "2.0.3"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.STRIDE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d5f4a36ba095f235070ad651434e74d4de3d63fe"
uuid = "850473c1-9ef0-5df9-a957-757f4cde8b8b"
version = "1.0.0+0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "712fb0231ee6f9120e005ccd56297abbc053e7e0"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.8"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "47091a0340a675c738b1304b58161f3b0839d454"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.10"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "29321314c920c26684834965ec2ce0dacc9cf8e5"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.4"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TestItems]]
git-tree-sha1 = "42fd9023fef18b9b78c8343a4e2f3813ffbcefcb"
uuid = "1c621080-faea-4a02-84b6-bbd5e436b8fe"
version = "1.0.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Trapz]]
git-tree-sha1 = "79eb0ed763084a3e7de81fe1838379ac6a23b6a0"
uuid = "592b5752-818d-11e9-1e9a-2b8ca4a44cd1"
version = "2.0.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "01915bfcd62be15329c9a07235447a89d588327c"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.1"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulAtomic]]
deps = ["Unitful"]
git-tree-sha1 = "903be579194534af1c4b4778d1ace676ca042238"
uuid = "a7773ee8-282e-5fa2-be4e-bd808c38a91a"
version = "1.0.0"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "a2fccc6559132927d4c5dc183e3e01048c6dcbd6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ecda72ccaf6a67c190c9adf27034ee569bccbc3a"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.3+1"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "ff1fdd02e71717c7418deb1c42f487529d0b9574"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+2"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7966eb654d74306e553ce28b9aea17969fc1966c"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+2"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6a0d3b4248b01faa44509c5ea363881d3ad3f5eb"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+2"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "fb3f116a4efb81aecf8c415e9423869c6ee0f21f"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+2"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9c7539767c23ed0db32fd50916d8f5807ee11af8"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+2"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4678b3c5ee394ae6422c415b231b8015c85542f"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+2"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "26ded386f85de26df35524639e525c2018f68ddd"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7dc5adc3f9bfb9b091b7952f4f6048b7e37acafc"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+2"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0ba42241cb6809f1a278d0bcb976e0483c3f1f2d"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+1"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "9c42636e3205e555e5785e902387be0061e7efc1"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─6edcdced-5fb5-41f4-a741-27c98dcbd1b4
# ╟─ea84b823-a39d-455c-be84-fe9dce10c4d8
# ╟─7ee8f5de-12d7-4dac-8933-a319ee6ed77a
# ╟─e5aedbda-67e9-465e-91f1-10125bee8dc0
# ╟─f9e5b61b-330d-40ee-8667-7af9012a6f62
# ╟─5fd21ecd-80ab-4d7f-ad64-cb33a399c289
# ╟─ca23c373-02c2-4e50-8c48-0cb2477eed59
# ╟─deaa5dbb-e0db-4f26-b4b4-af2c72bec167
# ╟─fb3f40bf-4b4b-4992-9eb7-667d8b12fe64
# ╟─23095d73-0957-450e-8537-72431506fd4d
# ╟─b2529e4f-a312-4adc-adf2-3f1f70a7b35f
# ╟─bb81d137-effe-4107-a61b-fd529cff8421
# ╟─813427fb-7d88-44f3-b118-2d5b94031a50
# ╟─4b30017b-ef13-45f1-8303-13a87b154841
# ╟─4d8bfae0-2eda-462b-a9ec-c0082097305d
# ╟─b188c630-5beb-40e3-9b92-260b385fc295
# ╟─e3e99ddc-36ea-4b53-bb07-753670a013db
# ╟─12fa8a68-6fed-4d1f-ac71-864ca078c5a7
# ╟─6a7e36c3-f441-46e5-8070-906ee366260d
# ╟─e8345099-906f-4965-bd3b-1d3f80eb2250
# ╠═a8fc4634-018b-4633-85b3-fb0ba639a49a
# ╟─53c3949d-6e77-4606-8882-db4a798eed2c
# ╟─9fa845c7-dd1e-40ea-9cd9-6126783aad94
# ╟─da89afa4-43bc-4906-b01b-9f6ec455f229
# ╟─025fed74-93a2-4bb9-96b6-9e4c1a00c75d
# ╟─681ecbaa-1370-468a-b3d8-7f01b373b3f6
# ╠═d904f54e-e284-46bb-b7a6-9fae79e01300
# ╠═5edbb407-3655-45f6-aa9b-8fae111b2eee
# ╠═62629866-b03e-4a61-b3fa-b6a12e3aa7c8
# ╟─5970ff0f-445f-4d27-8a54-56a7763c6e8c
# ╟─4f68effa-b334-4c85-b462-d5c6554e7ea3
# ╟─3b976cdf-09d2-4c43-881c-c1eadb4ea238
# ╟─19208b6e-7039-11ef-2685-c9fd57102877
# ╟─77c25151-8673-4ec1-9687-80f1fceb4e5c
# ╟─6f3ec99b-15b1-4014-b146-09e29864382c
# ╟─8293f49a-57a1-49b5-a2da-95a43b4cd097
# ╟─1ca88373-114c-464d-aaac-9f3b25893820
# ╟─90ad306d-163e-4fb3-a00e-6b86c32900f9
# ╟─357f0851-8ba2-4dbe-9c49-e5bd15f3f93b
# ╠═e30af672-9c42-4d19-8b5b-dbf1dc0d9680
# ╟─c08a180a-e8cf-4f02-9451-1d40fb96a653
# ╠═f9ec92d4-4ab4-4a9c-b240-7fe5d28e0018
# ╟─24202850-e8fa-4172-91f9-d31ad67e0d3e
# ╟─c18b8343-1911-4864-918f-2083637524d7
# ╠═72b526a6-6e22-40a1-ac76-8f766681ff87
# ╟─7027914f-2195-472e-968e-c5e587b84dba
# ╟─c1940fde-3164-40e7-8679-c16e872c38b8
# ╟─b18ed62a-9b12-467d-b289-7720a45817d3
# ╠═d4efcd42-14e6-46f0-85b7-0c917b09e7a1
# ╟─dd52ea0b-db95-4d07-8d12-cea548508033
# ╟─04514294-71e6-4185-b5a0-35eb09066e6f
# ╟─14f768ba-30e1-4fbb-ba80-70065873a830
# ╟─dbcd0df8-c2ee-4ba0-bcb5-75fe898b6f0f
# ╠═5a27e717-91ff-4d60-9e57-d32330121090
# ╟─6da7221d-55be-41c2-b74d-00e993d299f6
# ╠═68f2fa1e-cba9-4da9-ae13-9d0828c2bd15
# ╠═dff61cee-c2c4-41aa-8fc1-fbac08a67beb
# ╠═3bac1a1e-9bb1-4125-9b58-2bd43d959fa9
# ╠═b622c2a7-6e74-4b49-9e11-ad5b78508cd9
# ╠═04a3248a-9705-4c0f-bb44-5647fff61e81
# ╠═3b7d6a34-d8a3-4ad5-bf04-6fc2ccfe6bb3
# ╠═d5de2209-1980-481a-a7bd-9ed1d4ea7757
# ╠═d44450c2-fff7-4c4d-8231-57baab6cc404
# ╠═229dec7b-d92c-4c74-8a9f-fe21c3b0fb0d
# ╠═f8129573-5a9f-4989-a9f4-16659ef9b9af
# ╠═96e27383-8c0b-4b95-b7fb-80bb97f390bb
# ╠═5275bb7b-944d-4c25-a46d-44bda09d07e1
# ╠═4aaa1252-1f0f-4dde-b87e-9669bb3ecccb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
