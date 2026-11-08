import 'crop_forecast_models.dart';

/// Growth Phase information for a crop profile
class GrowthPhaseInfo {
  final String title;
  final String dayRange;
  final String description;
  final String keyActivity;

  const GrowthPhaseInfo({
    required this.title,
    required this.dayRange,
    required this.description,
    required this.keyActivity,
  });
}

/// Comprehensive Crop Profile for the Leafify Botanical Almanac
class CropProfile {
  final String id;
  final CropVariety variety;
  final String commonName;
  final String scientificName;
  final String family;
  final String summary;
  final String fullDescription;
  final String assetImage;
  final String bannerImage;
  final String idealTemperature;
  final String idealPh;
  final String idealEc;
  final String photoperiod;
  final String dli;
  final String cycleDuration;
  final String germinationDays;
  final String origin;
  final List<String> susceptibleDiseases;
  final List<String> careTips;
  final List<GrowthPhaseInfo> growthPhases;

  const CropProfile({
    required this.id,
    required this.variety,
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.summary,
    required this.fullDescription,
    required this.assetImage,
    required this.bannerImage,
    required this.idealTemperature,
    required this.idealPh,
    required this.idealEc,
    required this.photoperiod,
    required this.dli,
    required this.cycleDuration,
    required this.germinationDays,
    required this.origin,
    required this.susceptibleDiseases,
    required this.careTips,
    required this.growthPhases,
  });
}

/// Common Foliar Disease / Disorder Profile for the Leafify Botanical Almanac
class DiseaseProfile {
  final String id;
  final String name;
  final String scientificName;
  final String category; // 'Pathogenic' or 'Physiological Disorder'
  final String summary;
  final String fullDescription;
  final String assetImage;
  final String severityLevel;
  final List<String> affectedCrops;
  final List<String> visualSymptoms;
  final List<String> environmentalTriggers;
  final List<String> immediateTreatments;
  final List<String> preventativeMeasures;

  const DiseaseProfile({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.summary,
    required this.fullDescription,
    required this.assetImage,
    required this.severityLevel,
    required this.affectedCrops,
    required this.visualSymptoms,
    required this.environmentalTriggers,
    required this.immediateTreatments,
    required this.preventativeMeasures,
  });
}

/// Repository of all Crop Profiles and Common Diseases in Leafify Almanac
class AlmanacRepository {
  static const List<CropProfile> crops = [
    CropProfile(
      id: 'lettuce',
      variety: CropVariety.butterheadLettuce,
      commonName: 'Lettuce',
      scientificName: 'Lactuca sativa',
      family: 'Asteraceae (Aster family)',
      summary: 'Annual leaf vegetable. Member of the aster family (Asteraceae).',
      fullDescription:
          'Lettuce (Lactuca sativa) is a cool-season annual leafy vegetable characterized by a tender, rosette-forming canopy with dense, ruffled leaf blades. It is one of the premier crops for hydroponic Nutrient Film Technique (NFT) and Deep Water Culture (DWC) systems worldwide due to its compact root architecture, rapid vegetative growth velocity, and high commercial market value.',
      assetImage: 'assets/images/lettuce_almanac.png',
      bannerImage: 'assets/images/lettuce.png',
      idealTemperature: '16°C – 21°C (61°F – 70°F)',
      idealPh: '5.8 – 6.2',
      idealEc: '1.2 – 1.6 mS/cm',
      photoperiod: '14 – 16 hours / day',
      dli: '14.0 – 16.0 mol/m²/day',
      cycleDuration: '28 – 32 days from transplant',
      germinationDays: '2 – 4 days at 18°C–20°C',
      origin: 'Mediterranean Basin & Ancient Egypt',
      susceptibleDiseases: [
        'Bacterial Leaf Spot',
        'Leaf scorch (Tipburn)',
        'Chlorosis',
        'Downy Mildew',
      ],
      careTips: [
        'Maintain root-zone dissolved oxygen above 6.5 mg/L to avoid root pythium rot.',
        'Ensure steady horizontal canopy airflow (0.3–0.5 m/s) to prevent tipburn calcium deficiency.',
        'Keep water temperatures below 24°C to prevent premature bolting and bitter latex exudation.',
        'Use low ammonium-nitrogen ratios (<10%) to prevent excessive soft cell elongation.',
      ],
      growthPhases: [
        GrowthPhaseInfo(
          title: 'Phase 1: Germination & Emergence',
          dayRange: 'Days 1 – 4',
          description: 'Radicle emerges from seed coat; cotyledons expand under low PPFD (100 µmol/m²/s).',
          keyActivity: 'Maintain rockwool moisture with half-strength nursery nutrient solution (EC 0.8).',
        ),
        GrowthPhaseInfo(
          title: 'Phase 2: Seedling & Root Establishment',
          dayRange: 'Days 5 – 12',
          description: 'First true leaves develop; root radicles anchor into NFT channels or net pots.',
          keyActivity: 'Introduce full vegetative NFT flow; increase lighting to 14 mol/m²/day DLI.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 3: Vegetative Canopy Sprint',
          dayRange: 'Days 13 – 22',
          description: 'Exponential biomass accumulation; leaf surface area expands rapidly to canopy closure.',
          keyActivity: 'Maintain EC at 1.4 mS/cm and pH 6.0; inspect daily for foliar spots or chlorosis.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 4: Head Maturation & Harvest Window',
          dayRange: 'Days 23 – 30',
          description: 'Dense head tightening and petiole crispness reached; optimal fresh harvest weight attained.',
          keyActivity: 'Harvest in the early morning when plant turgor pressure and carbohydrate levels peak.',
        ),
      ],
    ),
    CropProfile(
      id: 'bok_choy',
      variety: CropVariety.bokChoy,
      commonName: 'Bok Choy',
      scientificName: 'Brassica rapa subsp. chinensis',
      family: 'Brassicaceae (Mustard family)',
      summary:
          'Member of the mustard family (Brassicaceae) that is a variety (chinensis) of Brassica rapa.',
      fullDescription:
          'Bok Choy (Brassica rapa subsp. chinensis), also called pak choi or Chinese white cabbage, is a fast-growing biennial leafy green revered for its thick, succulent white or light-green petioles and smooth, glossy emerald leaf blades. Highly responsive to hydroponic nutrient regimes, Bok Choy yields substantial fresh biomass in short 25–30 day cycles.',
      assetImage: 'assets/images/bok_choy_almanac.png',
      bannerImage: 'assets/images/bok_choy.png',
      idealTemperature: '18°C – 23°C (64°F – 73°F)',
      idealPh: '6.0 – 6.5',
      idealEc: '1.6 – 2.0 mS/cm',
      photoperiod: '12 – 14 hours / day',
      dli: '15.0 – 18.0 mol/m²/day',
      cycleDuration: '25 – 30 days from transplant',
      germinationDays: '2 – 3 days at 20°C–22°C',
      origin: 'Yangtze River Delta region of China',
      susceptibleDiseases: [
        'Bacterial Leaf Spot',
        'Chlorosis',
        'Downy Mildew',
        'Leaf scorch',
      ],
      careTips: [
        'Bok Choy is a heavy potassium and nitrogen consumer; maintain EC at 1.8 mS/cm during peak growth.',
        'Watch for high humidity condensation in tight leaf axils, which invites bacterial soft rots.',
        'Provide ample spacing (20–22 cm between centers) to encourage petiole thickening.',
        'Keep VPD within 0.9 – 1.1 kPa to balance transpiration and prevent foliar water congestion.',
      ],
      growthPhases: [
        GrowthPhaseInfo(
          title: 'Phase 1: Emergence & Cotyledon Expansion',
          dayRange: 'Days 1 – 3',
          description: 'Rapid radicle breakthrough; dark green heart-shaped cotyledons appear.',
          keyActivity: 'Nursery tray lighting at 150 µmol/m²/s; bottom-feed with EC 1.0 nutrient solution.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 2: Transplant & Vascular Anchor',
          dayRange: 'Days 4 – 10',
          description: 'Seedlings transferred to NFT channels; vigorous white root plumes extend into flow.',
          keyActivity: 'Calibrate nutrient stream to 1.5 L/min per channel; maintain pH 6.2.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 3: Petiole Thickening & Canopy Surge',
          dayRange: 'Days 11 – 20',
          description: 'Thick spoon-shaped petioles expand and fan outward; rapid cellular biomass increase.',
          keyActivity: 'Step up EC to 1.8–2.0 mS/cm; ensure adequate calcium and potassium uptake.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 4: Commercial Crispness & Harvest',
          dayRange: 'Days 21 – 28',
          description: 'Vase-shaped compact head with crisp, turgid stalks reaching target 200–250g weight.',
          keyActivity: 'Harvest before day 32 to prevent flower stalk initiation (bolting).',
        ),
      ],
    ),
    CropProfile(
      id: 'spinach',
      variety: CropVariety.spinach,
      commonName: 'Spinach',
      scientificName: 'Spinacia oleracea',
      family: 'Amaranthaceae',
      summary:
          'Edible flowering plant in the family Amaranthaceae native to central and western Asia.',
      fullDescription:
          'Spinach (Spinacia oleracea) is an ancient, nutrient-dense cool-weather leafy green celebrated for its deep emerald, iron-rich leaves and delicate texture. In controlled environment agriculture, hydroponic spinach requires strict root-zone oxygenation and lower water temperatures to achieve peak canopy yield and prevent root sensitivity.',
      assetImage: 'assets/images/spinach.png',
      bannerImage: 'assets/images/spinach.png',
      idealTemperature: '15°C – 20°C (59°F – 68°F)',
      idealPh: '6.0 – 6.6',
      idealEc: '1.4 – 1.8 mS/cm',
      photoperiod: '12 – 14 hours / day',
      dli: '12.0 – 14.0 mol/m²/day',
      cycleDuration: '24 – 28 days from transplant',
      germinationDays: '3 – 5 days at 15°C–18°C',
      origin: 'Ancient Persia (modern-day Iran)',
      susceptibleDiseases: [
        'Downy Mildew (Bremia / Peronospora)',
        'Chlorosis',
        'Bacterial Leaf Spot',
        'Leaf scorch',
      ],
      careTips: [
        'Extremely sensitive to root hypoxia; maintain root-zone dissolved oxygen > 7.0 ppm at all times.',
        'Keep nutrient solution temperature cool (17°C–19°C); water above 22°C triggers Pythium root rot.',
        'Avoid excessive day lengths (>14 hrs) combined with warm temperatures to prevent premature bolting.',
        'Maintain balanced nitrate-to-ammonium ratios to keep leaf lamina crisp and dark green.',
      ],
      growthPhases: [
        GrowthPhaseInfo(
          title: 'Phase 1: Cool Germination',
          dayRange: 'Days 1 – 4',
          description: 'Seeds germinate best in cool darkness; emergence of tender spear-shaped cotyledons.',
          keyActivity: 'Maintain germ chamber at 16°C; avoid over-saturation of starter plugs.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 2: True Leaf Emergence',
          dayRange: 'Days 5 – 11',
          description: 'First oval true leaves emerge with characteristic crinkled (savoy) or smooth texture.',
          keyActivity: 'Transplant to NFT or raft system; initiate nutrient solution at EC 1.2 mS/cm.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 3: Rosette Foliar Expansion',
          dayRange: 'Days 12 – 20',
          description: 'Rapid leaf blade widening and dark chlorophyll synthesis; basal rosette expansion.',
          keyActivity: 'Maintain EC 1.6 mS/cm and pH 6.2; ensure horizontal airflow across canopy.',
        ),
        GrowthPhaseInfo(
          title: 'Phase 4: Tender Leaf Harvest',
          dayRange: 'Days 21 – 26',
          description: 'Full canopy of succulent, tender leaves with peak iron, calcium, and antioxidant content.',
          keyActivity: 'Harvest whole rosettes or select outer leaves for continuous cut-and-come-again yields.',
        ),
      ],
    ),
  ];

  static const List<DiseaseProfile> diseases = [
    DiseaseProfile(
      id: 'chlorosis',
      name: 'Chlorosis',
      scientificName: 'Physiological / Micronutrient Deficiency',
      category: 'Physiological Disorder',
      summary:
          'Chlorosis is a yellowing of normally green leaves due to a lack of the pigment called chlorophyll.',
      fullDescription:
          'Chlorosis is a hallmark foliar symptom resulting from insufficient chlorophyll production in leaf chloroplasts. In hydroponic lettuce, bok choy, and spinach, chlorosis is typically triggered by nutrient imbalances (specifically iron, nitrogen, or magnesium deficiency), root-zone pH lockouts above 6.5, or root hypoxia limiting cation absorption.',
      assetImage: 'assets/images/chlorosis.png',
      severityLevel: 'Moderate (Reversible if caught early)',
      affectedCrops: ['Lettuce', 'Bok Choy', 'Spinach'],
      visualSymptoms: [
        'Interveinal yellowing with veins initially retaining green color (Iron deficiency).',
        'Uniform pale chartreuse fading across the entire leaf blade starting from older foliage (Nitrogen deficiency).',
        'Lower leaf margin yellowing progressing inward toward the midrib (Magnesium deficiency).',
        'Reduced photosynthesis, stunted growth rate, and thin leaf texture.',
      ],
      environmentalTriggers: [
        'Hydroponic solution pH drifting above 6.5, causing iron (Fe) and manganese (Mn) to precipitate out of solution.',
        'Depleted nitrogen reserves in recirculating reservoir tanks.',
        'Root zone hypoxia (DO < 4.0 ppm) causing root tip senescence and mineral uptake failure.',
        'Cold nutrient solution (< 15°C) suppressing biological nutrient absorption kinetics.',
      ],
      immediateTreatments: [
        'Step 1: Test and lower reservoir pH to 5.8 – 6.0 using hydroponic pH Down (phosphoric/nitric acid).',
        'Step 2: Add chelated iron (Fe-DTPA or Fe-EDDHA) at 1.5–2.0 ppm directly into the reservoir.',
        'Step 3: Administer a gentle foliar micronutrient spray (0.25 g/L chelated iron) during early photoperiod.',
        'Step 4: Drain and replenish 30% of reservoir volume with freshly balanced nutrient concentrate.',
      ],
      preventativeMeasures: [
        'Calibrate automated pH dosing pumps weekly with buffer calibration standards (pH 4.01 & 7.00).',
        'Maintain continuous air injection via venturi or air diffusers in the main reservoir (DO > 6.5 ppm).',
        'Keep nutrient solution temperatures regulated between 18°C and 21°C year-round.',
      ],
    ),
    DiseaseProfile(
      id: 'bacterial_leaf_spot',
      name: 'Bacterial Leaf Spot',
      scientificName: 'Xanthomonas campestris pv. vitians',
      category: 'Pathogenic Infection',
      summary:
          'Leaf spot diseases often appear initially as small round or oval dead areas, scattered over the surface of the leaf.',
      fullDescription:
          'Bacterial Leaf Spot is a destructive foliar disease caused by Xanthomonas campestris pv. vitians and Pseudomonas cichorii. It starts as tiny, translucent, water-soaked flecks that rapidly expand into angular brown-to-black necrotic lesions delineated by leaf veins. Under warm, humid microclimates, lesions coalesce, leading to extensive canopy collapse.',
      assetImage: 'assets/images/bacterial_spot.png',
      severityLevel: 'High / Infectious',
      affectedCrops: ['Lettuce', 'Bok Choy', 'Spinach'],
      visualSymptoms: [
        'Small, angular, water-soaked spots on leaf blades, visible on both upper and lower leaf surfaces.',
        'Spots turn dark brown to papery black as infected mesophyll tissue dies.',
        'Vein limitation causes lesions to have distinct angular or geometric borders.',
        'Yellow chlorotic halos surrounding necrotic spots in advanced infection stages.',
      ],
      environmentalTriggers: [
        'High relative humidity (> 85%) combined with stagnant, uncirculated air in the canopy.',
        'Water splashing or overhead misting depositing free moisture onto leaf surfaces.',
        'Canopy temperatures between 22°C and 28°C accelerating bacterial cell replication.',
        'Mechanical wounds or insect punctures facilitating bacterial entry through stomata.',
      ],
      immediateTreatments: [
        'Step 1: Immediately rogue and discard heavily infected plants in sealed disposal bags.',
        'Step 2: Reduce indoor greenhouse humidity to < 70% and increase horizontal airflow fans.',
        'Step 3: Cease any overhead foliar spraying or misting to keep leaf surfaces completely dry.',
        'Step 4: Apply a biological bio-fungicide (Bacillus subtilis or Bacillus amyloliquefaciens) to protect adjacent plants.',
      ],
      preventativeMeasures: [
        'Only source pathogen-free, certified disease-indexed seeds from accredited seed banks.',
        'Sterilize NFT channels, manifolds, and net pots with 10% hydrogen peroxide or peracetic acid between batches.',
        'Ensure generous spacing between plant net pots to avoid dense leaf-to-leaf contact.',
      ],
    ),
    DiseaseProfile(
      id: 'leaf_scorch',
      name: 'Leaf scorch',
      scientificName: 'Abiotic Physiological Necrosis / Tipburn',
      category: 'Physiological Disorder',
      summary:
          'Leaf scorch is a non-infectious condition caused by unfavorable environmental situations. It is not caused by any disease organism.',
      fullDescription:
          'Leaf scorch, commonly manifested as Tipburn in hydroponic leafy greens, is a localized calcium deficiency occurring at rapidly expanding leaf margins. While the nutrient solution may contain sufficient calcium, inadequate transpiration or rapid cell division prevents calcium ions from translocating to the enclosed inner leaf tips, causing marginal cell wall collapse and dry necrosis.',
      assetImage: 'assets/images/leaf_scorch.png',
      severityLevel: 'High / Market Degradation',
      affectedCrops: ['Lettuce', 'Bok Choy', 'Spinach'],
      visualSymptoms: [
        'Browning, curling, and dieback of young leaf margins and tips in the inner rosette.',
        'Papery crisp, scorched edges on fast-growing leaves while mature outer leaves remain normal.',
        'Secondary invasion of scorched dead margins by opportunistic Botrytis or soft rot bacteria.',
        'Deformed, cupped leaf blades due to restricted edge expansion.',
      ],
      environmentalTriggers: [
        'Excessive vegetative growth velocity driven by intense lighting (DLI > 17) or high temperature (> 24°C).',
        'Stagnant microclimate inside inner heart leaves preventing transpiration-driven calcium translocation.',
        'High electrical conductivity (EC > 2.0 mS/cm) causing osmotic resistance to calcium absorption.',
        'High nighttime humidity (> 90%) inhibiting root pressure guttation and calcium transport.',
      ],
      immediateTreatments: [
        'Step 1: Increase vertical and horizontal air circulation directly aimed into the plant rosette centers.',
        'Step 2: Lower nutrient solution EC by 0.2–0.3 mS/cm to ease root osmotic water absorption.',
        'Step 3: Reduce daytime temperature by 2°C–3°C or shade peak photoperiod hours.',
        'Step 4: Trim scorched outer leaf margins if plants are approaching commercial harvest.',
      ],
      preventativeMeasures: [
        'Install dedicated inner-canopy circulation fans (air speed 0.3–0.5 m/s at canopy level).',
        'Maintain solution Calcium:Potassium ratio of at least 1:2 in the hydroponic fertilizer mix.',
        'Regulate nighttime Vapor Pressure Deficit (VPD) between 0.4 and 0.6 kPa to promote healthy guttation.',
      ],
    ),
    DiseaseProfile(
      id: 'downy_mildew',
      name: 'Downy Mildew',
      scientificName: 'Bremia lactucae / Peronospora effusa',
      category: 'Pathogenic Infection',
      summary:
          'Aggressive foliar oomycete producing pale angular chlorotic patches on the upper leaf with white-gray downy sporulation below.',
      fullDescription:
          'Downy Mildew is one of the most widespread and economically damaging diseases in commercial leafy greens cultivation. Caused by Bremia lactucae on lettuce and Peronospora effusa on spinach, it thrives under cool, damp conditions, invading stomata and systematically degrading foliar tissue quality.',
      assetImage: 'assets/images/spinach.png',
      severityLevel: 'Very High / Epidemic Potential',
      affectedCrops: ['Spinach', 'Lettuce'],
      visualSymptoms: [
        'Pale yellow to light green angular patches on the upper leaf surface, bordered by large veins.',
        'Downy, felt-like white to grayish-purple fungal sporulation on the corresponding leaf undersides.',
        'Lesions rapidly turn brown and dry as infected foliar cells collapse.',
        'Systemic leaf distortion and stunting in young seedlings.',
      ],
      environmentalTriggers: [
        'Prolonged leaf wetness for more than 3–4 consecutive hours.',
        'Cool temperatures (10°C – 18°C) paired with high relative humidity (> 88%).',
        'Poor greenhouse ventilation and dense, overlapping crop canopies.',
      ],
      immediateTreatments: [
        'Step 1: Remove and safely incinerate all leaves exhibiting downy sporulation.',
        'Step 2: Raise greenhouse ambient temperature to above 21°C to inhibit Bremia sporulation.',
        'Step 3: Run dehumidifiers and heat/vent cycles to prevent nighttime dew point condensation.',
        'Step 4: Apply approved potassium phosphite or bio-fungicide preventative drench.',
      ],
      preventativeMeasures: [
        'Select modern resistant cultivars possessing full Bremia resistance genes (Bl: 1–39).',
        'Strictly enforce zero overhead irrigation; maintain dry foliage at all times.',
        'Sanitize greenhouse structural benches, air ducts, and gutters between crop rotations.',
      ],
    ),
  ];
}

