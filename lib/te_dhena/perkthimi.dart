/// Shqip dhe anglisht, në një skedar.
///
/// Loja lind shqip — ky është vendi ku ajo shkruhet — por një lojë enigmash pa
/// tekst në lojë nuk ka arsye të mbetet vetëm shqip: e vetmja gjë që ndryshon
/// mes dy gjuhëve janë menytë. Pa anglishten, dyqani i ka lexuesit e vet të
/// kufizuar në pak milionë veta.
library;

enum Gjuha { shqip, anglisht }

const _sq = <String, String>{
  'titulli': 'Girih',
  'moto': 'Lidh nyjet, zbulo yllin',
  'luaj': 'Luaj',
  'vazhdo': 'Vazhdo',
  'botet': 'Botët',
  'ditorja': 'Sfida e ditës',
  'statistika': 'Statistika',
  'cilesimet': 'Cilësimet',
  'si_luhet': 'Si luhet',
  'bota': 'Bota',
  'niveli': 'Niveli',
  'levizje': 'Lëvizje',
  'nyje': 'Nyje',
  'ndihme': 'Ndihmë',
  'zhbej': 'Zhbëj',
  'rifillo': 'Rifillo',
  'nivelet': 'Nivelet',
  'paraardhesi': 'Niveli i mëparshëm',
  'perfekt': 'Përsosur!',
  'zgjidhur': 'U zgjidh!',
  'tjetri': 'Niveli tjetër',
  'perserit': 'Përsërite',
  'dil': 'Dil',
  'mbyll': 'Mbyll',
  'e_kycur': 'E kyçur',
  'zhbllokohet': 'Mbaro @n nivele te bota e mëparshme',
  'yje': 'yje',
  'ndihma_mbetur': 'Ndihma të mbetura',
  'pa_ndihma': 'S\'ke më ndihma — mbaro nivele për të fituar të reja',
  'pa_ndihma_titull': 'S\'ke më ndihma',
  'ndihme_me_reklame': 'Shih një reklamë të shkurtër dhe merr një ndihmë. '
      'Ndihma jepet edhe nëse reklama nuk ngarkohet.',
  'shih_reklamen': 'Shih reklamën',
  'jo_faleminderit': 'Jo, faleminderit',
  // Shfaqet vetëm kur çdo çift është lidhur por rrjeta ka mbetur me vrima —
  // çasti i vetëm ku lojtari mendon se e mbaroi nivelin dhe loja hesht.
  'mbeten_qeliza': 'Të gjitha nyjet janë lidhur — mbeten @n qeliza bosh',
  'seria': 'Seria',
  'dite': 'ditë',
  'gjuha': 'Gjuha',
  'pamja': 'Pamja',
  'erret': 'E errët',
  'ndritshem': 'E ndritshme',
  'pergamene': 'Pergamenë',
  'daltonik': 'Ngjyra për daltonizëm',
  'shenja': 'Numra mbi nyje',
  'dridhje': 'Dridhje',
  'animacione': 'Animacione',
  'ndaj': 'Ndaje',
  'kopjuar': 'U kopjua te kujtesa',
  'gjithsej_zgjidhur': 'Nivele të zgjidhura',
  'gjithsej_yje': 'Yje të fituar',
  'perfekte': 'Nivele të përsosura',
  'arritjet': 'Arritjet',
  'ndihmesa_1': 'Tërhiq nga një nyje te binjakja e saj.',
  'ndihmesa_2': 'Çdo qelizë duhet mbushur — jo vetëm nyjet e lidhura.',
  'ndihmesa_3': 'Kalimi mbi një litar tjetër e pret atë; s\'prish punë.',
  'ndihmesa_4': 'Tre yje: pa ndihmë dhe pa e vizatuar dy herë asnjë litar.',
  'zbrazur': 'Ende asgjë këtu.',
  'e_perfunduar': 'E përfunduar',
  'ditorja_bere': 'Sfida e sotme u zgjidh. Kthehu nesër!',
  'rifillo_gjithcka': 'Fshij çdo përparim',
  'vlereso': 'Vlerëso lojën te Play',
  'je_i_sigurt': 'A je i sigurt? Kjo nuk kthehet.',
  'po': 'Po',
  'jo': 'Jo',
};

const _en = <String, String>{
  'titulli': 'Girih',
  'moto': 'Connect the knots, reveal the star',
  'luaj': 'Play',
  'vazhdo': 'Continue',
  'botet': 'Worlds',
  'ditorja': 'Daily challenge',
  'statistika': 'Statistics',
  'cilesimet': 'Settings',
  'si_luhet': 'How to play',
  'bota': 'World',
  'niveli': 'Level',
  'levizje': 'Moves',
  'nyje': 'Knots',
  'ndihme': 'Hint',
  'zhbej': 'Undo',
  'rifillo': 'Restart',
  'nivelet': 'Levels',
  'paraardhesi': 'Previous level',
  'perfekt': 'Perfect!',
  'zgjidhur': 'Solved!',
  'tjetri': 'Next level',
  'perserit': 'Play again',
  'dil': 'Exit',
  'mbyll': 'Close',
  'e_kycur': 'Locked',
  'zhbllokohet': 'Finish @n levels in the previous world',
  'yje': 'stars',
  'ndihma_mbetur': 'Hints left',
  'pa_ndihma': 'No hints left — finish levels to earn more',
  'pa_ndihma_titull': 'No hints left',
  'ndihme_me_reklame': 'Watch a short ad and get one hint. '
      'You get the hint even if the ad fails to load.',
  'shih_reklamen': 'Watch the ad',
  'jo_faleminderit': 'No, thanks',
  'mbeten_qeliza': 'Every knot is linked — @n cells are still empty',
  'seria': 'Streak',
  'dite': 'days',
  'gjuha': 'Language',
  'pamja': 'Theme',
  'erret': 'Dark',
  'ndritshem': 'Light',
  'pergamene': 'Parchment',
  'daltonik': 'Colour-blind palette',
  'shenja': 'Numbers on knots',
  'dridhje': 'Haptics',
  'animacione': 'Animations',
  'ndaj': 'Share',
  'kopjuar': 'Copied to clipboard',
  'gjithsej_zgjidhur': 'Levels solved',
  'gjithsej_yje': 'Stars earned',
  'perfekte': 'Perfect levels',
  'arritjet': 'Achievements',
  'ndihmesa_1': 'Drag from a knot to its twin.',
  'ndihmesa_2': 'Every cell must be filled — not just the knots joined.',
  'ndihmesa_3': 'Crossing another rope cuts it; that is allowed.',
  'ndihmesa_4': 'Three stars: no hints, and no rope drawn twice.',
  'zbrazur': 'Nothing here yet.',
  'e_perfunduar': 'Complete',
  'ditorja_bere': 'Today\'s challenge is solved. Come back tomorrow!',
  'rifillo_gjithcka': 'Erase all progress',
  'vlereso': 'Rate the game on Play',
  'je_i_sigurt': 'Are you sure? This cannot be undone.',
  'po': 'Yes',
  'jo': 'No',
};

/// Emrat e botëve dhe të arritjeve rrinë veç, sepse janë emërtime dhe jo fjalë
/// ndërfaqeje: në shqip mbeten të njëjtët edhe kur loja lexohet në anglisht.
const emratEBoteve = <String>[
  'Fillimi',
  'Rrota',
  'Ylli',
  'Kupa',
  'Harku',
  'Oborri',
  'Kupola',
  'Nyja',
];

class Fjalor {
  const Fjalor(this.gjuha);
  final Gjuha gjuha;

  String call(String celes, {Map<String, Object>? vlera}) {
    final harta = gjuha == Gjuha.shqip ? _sq : _en;
    var s = harta[celes] ?? _sq[celes] ?? celes;
    if (vlera != null) {
      vlera.forEach((k, v) => s = s.replaceAll('@$k', '$v'));
    }
    return s;
  }
}
