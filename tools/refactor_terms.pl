#!/usr/bin/perl
# One-off terminology refactor (Brief 14, Part A): applies the Design Guidance terms to GDScript
# identifiers (code segments) and to prose (string literals and comments).
# Usage: perl tools/refactor_terms.pl file.gd ...
use strict;
use warnings;

my %GAMEFILES_POWER = map { $_ => 1 } qw(
  capital_content card_builder card_data content_definitions heap_content multipath_content
  progression_content challenge_data challenge_examples challenge_resolver element_choice combat_resolver
  game_state quest zone_effects card_view deckbuilder_screen fourth_brief_final_smoke sixth_brief_final_smoke
  test_ai_player test_data_model test_challenges test_graveyard_boss test_trial test_combat test_effects
  test_equipment_modifiers test_scripted_encounters test_content test_zone_effects game_factory modifier modifier_set
  effect_data
);

sub code_rules {
    my ($s, $file) = @_;
    # keyword enums
    $s =~ s/\bREACH\b/SWAT/g;
    $s =~ s/\bHASTE\b/HUSTLE/g;
    $s =~ s/\bDEFENDER\b/WALLFLOWER/g;
    $s =~ s/\bTRAMPLE\b/BULLDOZE/g;
    $s =~ s/\bFIRST_STRIKE\b/SUCKER_PUNCH/g;
    $s =~ s/\bLIFESTEAL\b/NOURISH/g;
    $s =~ s/\bVIGILANCE\b/OVERTIME/g;
    $s =~ s/_apply_lifesteal/_apply_nourish/g;
    $s =~ s/\blifesteal\b/nourish/g;
    # creature -> unit
    $s =~ s/CREATURES/UNITS/g; $s =~ s/CREATURE/UNIT/g;
    $s =~ s/Creatures/Units/g; $s =~ s/Creature/Unit/g;
    $s =~ s/creatures/units/g; $s =~ s/creature/unit/g;
    $s =~ s/\bkill_unit\b/destroy_unit/g;
    # zones
    $s =~ s/battlefield/field/g; $s =~ s/Battlefield/Field/g; $s =~ s/BATTLEFIELD/FIELD/g;
    $s =~ s/\.graveyard\b/.refuse_pile/g;
    $s =~ s/_send_to_graveyard/_send_to_refuse_pile/g;
    $s =~ s/_maybe_return_from_graveyard/_maybe_return_from_refuse_pile/g;
    $s =~ s/\bdeep_library\b/deep_deck/g;
    $s =~ s/\blibrary\b/deck/g;
    # stats
    $s =~ s/toughness/defense/g; $s =~ s/Toughness/Defense/g; $s =~ s/TOUGHNESS/DEFENSE/g;
    $s =~ s/\bget_power\b/get_attack/g;
    $s =~ s/\bpower_bonus\b/attack_bonus/g;
    $s =~ s/\btemp_power\b/temp_attack/g;
    $s =~ s/\b_base_power\b/_base_attack/g;
    $s =~ s/\b_power_label\b/_attack_label/g;
    $s =~ s/\bSTANDARD_POWER\b/STANDARD_ATTACK/g;
    $s =~ s/\bFIRST_UNIT_POWER\b/FIRST_UNIT_ATTACK/g;
    my ($base) = $file =~ m{([^/\\]+)\.gd$};
    if ($base && $GAMEFILES_POWER{$base}) { $s =~ s/\bpower\b/attack/g; }
    # HP
    $s =~ s/(?<![A-Za-z])life(?![a-z])/hp/g;
    $s =~ s/(?<![A-Za-z])LIFE(?![A-Za-z])/HP/g;
    $s =~ s/(?<=[a-z])Life(?![a-z])/Hp/g;
    # play / cast
    $s =~ s/\bcan_cast\b/can_play_card/g;
    $s =~ s/\bGameAction\.cast\b/GameAction.play_card/g;
    $s =~ s/\.cast\(/.play_card(/g;
    $s =~ s/\bfunc cast\(/func play_card(/g;
    $s =~ s/\bCAST\b/PLAY/g;
    $s =~ s/\bCARD_CAST\b/CARD_PLAYED/g;
    $s =~ s/\bcast_from_hand\b/played_from_hand/g;
    $s =~ s/non_infrastructure_casts_this_turn/non_infrastructure_plays_this_turn/g;
    $s =~ s/non_infrastructure_cast_cap/non_infrastructure_play_cap/g;
    $s =~ s/MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN/MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN/g;
    $s =~ s/NO_UNIT_CASTS/NO_UNIT_PLAYS/g;
    # mill / discard / bounce
    $s =~ s/\bMILL\b/BURY/g;
    $s =~ s/\bCARD_MILLED\b/CARD_BURIED/g;
    $s =~ s/\bmill_cards\b/bury_cards/g;
    $s =~ s/\bDISCARD\b/TOSS/g;
    $s =~ s/\bCARD_DISCARDED\b/CARD_TOSSED/g;
    $s =~ s/\bdiscard_card\b/toss_card/g;
    $s =~ s/\bpending_discard\b/pending_toss/g;
    $s =~ s/\bdiscard_for_hand_size\b/toss_for_hand_size/g;
    $s =~ s/\bRETURN_TO_HAND\b/SEND_BACK/g;
    $s =~ s/\breturn_to_hand\b/send_back/g;
    $s =~ s/\bCARD_RETURNED_TO_HAND\b/CARD_SENT_BACK/g;
    # Paths
    $s =~ s/\bAffinity\.Type\.A\b/Affinity.Type.BEEFCAKE/g;
    $s =~ s/\bAffinity\.Type\.B\b/Affinity.Type.GOURMAND/g;
    $s =~ s/\bAffinity\.Type\.C\b/Affinity.Type.REFUSEMANCER/g;
    $s =~ s/\bAffinity\.Type\.D\b/Affinity.Type.NECROCRAT/g;
    return $s;
}

sub prose_rules {
    my ($s, $file) = @_;
    $s =~ s/toughness/defense/g; $s =~ s/Toughness/Defense/g;
    $s =~ s/STANDARDIZE_CREATURES/STANDARDIZE_UNITS/g;
    my ($pbase) = ($file // "") =~ m{([^/]+)[.]gd$};
    if ($pbase && $GAMEFILES_POWER{$pbase}) { $s =~ s/\bpower\b/attack/g; $s =~ s/\bPower\b/Attack/g; }
    $s =~ s/creatures/units/g; $s =~ s/creature/unit/g;
    $s =~ s/Creatures/Units/g; $s =~ s/Creature/Unit/g;
    $s =~ s/\bthe battlefield\b/the field/g;
    $s =~ s/battlefield/field/g; $s =~ s/Battlefield/Field/g;
    $s =~ s/(?<![A-Za-z])life(?![a-z])/HP/g;
    $s =~ s/(?<![A-Za-z])Life(?![a-z])/HP/g;
    $s =~ s/\bPath energy\b/energy/g; $s =~ s/\bPath Energy\b/Energy/g;
    $s =~ s/\bmana\b/energy/g;
    $s =~ s/\bcasting\b/playing/g; $s =~ s/\bCasting\b/Playing/g;
    $s =~ s/\bcasts\b/plays/g; $s =~ s/\bCasts\b/Plays/g;
    $s =~ s/\bcast\b/play/g; $s =~ s/\bCast\b/Play/g;
    $s =~ s/\bHaste\b/Hustle/g; $s =~ s/\bVigilance\b/Overtime/g;
    $s =~ s/\bTrample\b/Bulldoze/g; $s =~ s/\btrample\b/bulldoze/g;
    $s =~ s/\b[Ff]irst strike\b/Sucker Punch/g;
    $s =~ s/\bLifesteal\b/Nourish/g;
    $s =~ s/\blibrary\b/deck/g;
    $s =~ s/\bgraveyard\b(?= of| zone| pile)/Refuse Pile/g;
    return $s;
}

my $DETECT = ($ARGV[0] eq '--detect') ? 1 : 0;
shift @ARGV if $DETECT;

foreach my $file (@ARGV) {
    open(my $in, '<:raw', $file) or die "$file: $!";
    local $/ = undef;
    my $text = <$in>;
    close $in;
    next if $text =~ /"""/;
    my @lines = split(/(?<=\n)/, $text);
    my @out;
    my $open_q = '';      # quote char of a string literal that continues across lines
    my $multi = 0;
    foreach my $line (@lines) {
        my $res = '';
        my $i = 0;
        my $n = length($line);
        my $code = '';
        while ($i < $n) {
            my $c = substr($line, $i, 1);
            if ($open_q ne '' || $c eq '"' || $c eq "'") {
                my $q;
                my $j;
                if ($open_q ne '') { $q = $open_q; $j = $i; }
                else { $q = $c; $j = $i + 1; $res .= code_rules($code, $file); $code = ''; }
                my $str = '';
                my $closed = 0;
                while ($j < $n) {
                    my $d = substr($line, $j, 1);
                    if ($d eq '\\') { $str .= substr($line, $j, 2); $j += 2; next; }
                    if ($d eq $q) { $closed = 1; last; }
                    $str .= $d; $j++;
                }
                my $fresh = ($open_q eq '');
                if (!$closed) { $multi++; $open_q = $q; } else { $open_q = ''; }
                if ($fresh && $closed && $str =~ /^[A-Za-z_]+$/) { $str = code_rules($str, $file); }
                elsif ($fresh && $closed && ($str =~ m{^(res|user|uid)://} || ($str !~ /\s/ && $str =~ m{/}))) { }
                else { $str = prose_rules($str, $file); }
                $res .= ($fresh ? $q : '') . $str . ($closed ? $q : '');
                $i = $closed ? $j + 1 : $n;
            } elsif ($c eq '#') {
                $res .= code_rules($code, $file); $code = '';
                $res .= prose_rules(substr($line, $i), $file);
                $i = $n;
            } else {
                $code .= $c; $i++;
            }
        }
        $res .= code_rules($code, $file);
        push @out, $res;
    }
    if ($DETECT) { print "$file $multi\n" if $multi; next; }
    my $new = join('', @out);
    if ($new ne $text) {
        open(my $o, '>:raw', $file) or die "$file: $!";
        print $o $new;
        close $o;
    }
}
