require 'rails_helper'

describe TokenStemmer do
  let(:stemmer) { TokenStemmer.new }

  it 'keep verbs in present plain form' do
    expect(stem('くう')).to include('くう')
    expect(stem('解く')).to include('解く')
    expect(stem('たつ')).to include('たつ')
    expect(stem('飛ぶ')).to include('飛ぶ')
    expect(stem('とる')).to include('とる')
    expect(stem('頼む')).to include('頼む')
    expect(stem('しぬ')).to include('しぬ')
    expect(stem('出す')).to include('出す')
    expect(stem('ねる')).to include('ねる')
    expect(stem('着る')).to include('着る')
  end

  it 'stem verbs in present formal form' do
    expect(stem('洗います')).to include('洗う')
    expect(stem('かきます')).to include('かく')
    expect(stem('立ちます')).to include('立つ')
    expect(stem('よびます')).to include('よぶ')
    expect(stem('のります')).to include('のる')
    expect(stem('飲みます')).to include('飲む')
    expect(stem('しにます')).to include('しぬ')
    expect(stem('汚します')).to include('汚す')
    expect(stem('たべます')).to include('たべる')
    expect(stem('出来ます')).to include('出来る')
  end

  it 'stem negative verbs in present plain form' do
    expect(stem('洗わない')).to include('洗う')
    expect(stem('かかない')).to include('かく')
    expect(stem('立たない')).to include('立つ')
    expect(stem('よばない')).to include('よぶ')
    expect(stem('のらない')).to include('のる')
    expect(stem('飲まない')).to include('飲む')
    expect(stem('しなない')).to include('しぬ')
    expect(stem('汚さない')).to include('汚す')
    expect(stem('たべない')).to include('たべる')
    expect(stem('出来ない')).to include('出来る')
  end

  it 'stem negative verbs in present formal form' do
    expect(stem('くいません')).to include('くう')
    expect(stem('解きません')).to include('解く')
    expect(stem('たちません')).to include('たつ')
    expect(stem('飛びません')).to include('飛ぶ')
    expect(stem('とりません')).to include('とる')
    expect(stem('頼みません')).to include('頼む')
    expect(stem('しにません')).to include('しぬ')
    expect(stem('出しません')).to include('出す')
    expect(stem('ねませんです')).to include('ねる')
    expect(stem('着ませんです')).to include('着る')
  end

  it 'stem verbs in past plain form' do
    expect(stem('くった')).to include('くう')
    expect(stem('解いた')).to include('解く')
    expect(stem('たった')).to include('たつ')
    expect(stem('飛んだ')).to include('飛ぶ')
    expect(stem('とった')).to include('とる')
    expect(stem('頼んだ')).to include('頼む')
    expect(stem('しんだ')).to include('しぬ')
    expect(stem('出した')).to include('出す')
    expect(stem('ねた')).to include('ねる')
    expect(stem('着た')).to include('着る')
  end

  it 'stem verbs in past formal form' do
    expect(stem('洗いました')).to include('洗う')
    expect(stem('かきました')).to include('かく')
    expect(stem('立ちました')).to include('立つ')
    expect(stem('よびました')).to include('よぶ')
    expect(stem('のりました')).to include('のる')
    expect(stem('飲みました')).to include('飲む')
    expect(stem('しにました')).to include('しぬ')
    expect(stem('汚しました')).to include('汚す')
    expect(stem('たべました')).to include('たべる')
    expect(stem('出来ました')).to include('出来る')
  end

  it 'stem negative verbs in past plain form' do
    expect(stem('洗わなかった')).to include('洗う')
    expect(stem('かかなかった')).to include('かく')
    expect(stem('立たなかった')).to include('立つ')
    expect(stem('よばなかった')).to include('よぶ')
    expect(stem('のらなかった')).to include('のる')
    expect(stem('飲まなかった')).to include('飲む')
    expect(stem('しななかった')).to include('しぬ')
    expect(stem('汚さなかった')).to include('汚す')
    expect(stem('たべなかった')).to include('たべる')
    expect(stem('出来なかった')).to include('出来る')
  end

  it 'stem -te verbs in plain form' do
    expect(stem('くって')).to include('くう')
    expect(stem('解いて')).to include('解く')
    expect(stem('たって')).to include('たつ')
    expect(stem('飛んで')).to include('飛ぶ')
    expect(stem('とって')).to include('とる')
    expect(stem('頼んで')).to include('頼む')
    expect(stem('しんで')).to include('しぬ')
    expect(stem('出して')).to include('出す')
    expect(stem('ねて')).to include('ねる')
    expect(stem('着て')).to include('着る')
  end

  it 'stem -te verbs in formal form' do
    expect(stem('洗いまして')).to include('洗う')
    expect(stem('かきまして')).to include('かく')
    expect(stem('立ちまして')).to include('立つ')
    expect(stem('よびまして')).to include('よぶ')
    expect(stem('のりまして')).to include('のる')
    expect(stem('飲みまして')).to include('飲む')
    expect(stem('しにまして')).to include('しぬ')
    expect(stem('汚しまして')).to include('汚す')
    expect(stem('たべまして')).to include('たべる')
    expect(stem('出来まして')).to include('出来る')
  end

  it 'stem negative -te verbs in plain form' do
    expect(stem('洗わなくって')).to include('洗う')
    expect(stem('かかなくって')).to include('かく')
    expect(stem('立たなくって')).to include('立つ')
    expect(stem('よばなくって')).to include('よぶ')
    expect(stem('のらなくって')).to include('のる')
    expect(stem('飲まなくって')).to include('飲む')
    expect(stem('しななくって')).to include('しぬ')
    expect(stem('汚さなくって')).to include('汚す')
    expect(stem('たべなくて')).to include('たべる')
    expect(stem('出来なくて')).to include('出来る')
  end

  it 'stem conditional verbs in plain form' do
    expect(stem('くったら')).to include('くう')
    expect(stem('解いたら')).to include('解く')
    expect(stem('たったら')).to include('たつ')
    expect(stem('飛んだら')).to include('飛ぶ')
    expect(stem('とったら')).to include('とる')
    expect(stem('頼んだら')).to include('頼む')
    expect(stem('しんだら')).to include('しぬ')
    expect(stem('出したら')).to include('出す')
    expect(stem('ねたら')).to include('ねる')
    expect(stem('着たら')).to include('着る')
  end

  it 'stem conditional verbs in formal form' do
    expect(stem('洗いましたら')).to include('洗う')
    expect(stem('かきましたら')).to include('かく')
    expect(stem('立ちましたら')).to include('立つ')
    expect(stem('よびましたら')).to include('よぶ')
    expect(stem('のりましたら')).to include('のる')
    expect(stem('飲みましたら')).to include('飲む')
    expect(stem('しにましたら')).to include('しぬ')
    expect(stem('汚しましたら')).to include('汚す')
    expect(stem('たべましたら')).to include('たべる')
    expect(stem('出来ましたら')).to include('出来る')
  end

  it 'stem negative conditional verbs in plain form' do
    expect(stem('洗わなかったら')).to include('洗う')
    expect(stem('かかなかったら')).to include('かく')
    expect(stem('立たなかったら')).to include('立つ')
    expect(stem('よばなかったら')).to include('よぶ')
    expect(stem('のらなかったら')).to include('のる')
    expect(stem('飲まなかったら')).to include('飲む')
    expect(stem('しななかったら')).to include('しぬ')
    expect(stem('汚さなかったら')).to include('汚す')
    expect(stem('たべなかったら')).to include('たべる')
    expect(stem('出来なかったら')).to include('出来る')
  end

  it 'stem provisional verbs in plain form' do
    expect(stem('くえば')).to include('くう')
    expect(stem('解けば')).to include('解く')
    expect(stem('たてば')).to include('たつ')
    expect(stem('飛べば')).to include('飛ぶ')
    expect(stem('とれば')).to include('とる')
    expect(stem('頼めば')).to include('頼む')
    expect(stem('しねば')).to include('しぬ')
    expect(stem('出せば')).to include('出す')
    expect(stem('ねれば')).to include('ねる')
    expect(stem('着れば')).to include('着る')
  end

  it 'stem provisional verbs in formal form' do
    expect(stem('洗いませば')).to include('洗う')
    expect(stem('かきませば')).to include('かく')
    expect(stem('立ちませば')).to include('立つ')
    expect(stem('よびませば')).to include('よぶ')
    expect(stem('のりませば')).to include('のる')
    expect(stem('飲みませば')).to include('飲む')
    expect(stem('しにませば')).to include('しぬ')
    expect(stem('汚しませば')).to include('汚す')
    expect(stem('たべませば')).to include('たべる')
    expect(stem('出来ませば')).to include('出来る')
  end

  it 'stem negative provisional verbs in plain form' do
    expect(stem('洗わなければ')).to include('洗う')
    expect(stem('かかなければ')).to include('かく')
    expect(stem('立たなければ')).to include('立つ')
    expect(stem('よばなくちゃ')).to include('よぶ')
    expect(stem('のらなくちゃ')).to include('のる')
    expect(stem('飲まなくちゃ')).to include('飲む')
    expect(stem('しななきゃ')).to include('しぬ')
    expect(stem('汚さなきゃ')).to include('汚す')
    expect(stem('たべなければ')).to include('たべる')
    expect(stem('出来なくちゃ')).to include('出来る')
  end

  it 'stem potential verbs in plain form' do
    expect(stem('くえる')).to include('くう')
    expect(stem('解ける')).to include('解く')
    expect(stem('たてる')).to include('たつ')
    expect(stem('飛べる')).to include('飛ぶ')
    expect(stem('とれる')).to include('とる')
    expect(stem('頼める')).to include('頼む')
    expect(stem('しねる')).to include('しぬ')
    expect(stem('出せる')).to include('出す')
    expect(stem('ねられる')).to include('ねる')
    expect(stem('着られる')).to include('着る')
  end

  it 'stem potential verbs in formal form' do
    expect(stem('洗えます')).to include('洗う')
    expect(stem('かけます')).to include('かく')
    expect(stem('立てます')).to include('立つ')
    expect(stem('よべます')).to include('よぶ')
    expect(stem('のれます')).to include('のる')
    expect(stem('飲めます')).to include('飲む')
    expect(stem('しねます')).to include('しぬ')
    expect(stem('汚せます')).to include('汚す')
    expect(stem('たべられます')).to include('たべる')
    expect(stem('出来られます')).to include('出来る')
  end

  it 'stem volitional verbs in plain form' do
    expect(stem('洗おう')).to include('洗う')
    expect(stem('かこう')).to include('かく')
    expect(stem('立とう')).to include('立つ')
    expect(stem('よぼう')).to include('よぶ')
    expect(stem('のろう')).to include('のる')
    expect(stem('飲もう')).to include('飲む')
    expect(stem('しのう')).to include('しぬ')
    expect(stem('汚そう')).to include('汚す')
    expect(stem('たべよう')).to include('たべる')
    expect(stem('着よう')).to include('着る')
  end
  
  it 'stem volitional verbs in formal form' do
    expect(stem('くいましょう')).to include('くう')
    expect(stem('解きましょう')).to include('解く')
    expect(stem('たちましょう')).to include('たつ')
    expect(stem('飛びましょう')).to include('飛ぶ')
    expect(stem('とりましょう')).to include('とる')
    expect(stem('頼みましょう')).to include('頼む')
    expect(stem('しにましょう')).to include('しぬ')
    expect(stem('出しましょう')).to include('出す')
    expect(stem('ねましょう')).to include('ねる')
    expect(stem('着ましょう')).to include('着る')
  end

  it 'stem passive verbs in plain form' do
    expect(stem('くわれる')).to include('くう')
    expect(stem('解かれる')).to include('解く')
    expect(stem('たたれる')).to include('たつ')
    expect(stem('飛ばれる')).to include('飛ぶ')
    expect(stem('とられる')).to include('とる')
    expect(stem('頼まれる')).to include('頼む')
    expect(stem('しなれる')).to include('しぬ')
    expect(stem('出される')).to include('出す')
    expect(stem('ねられる')).to include('ねる')
    expect(stem('着られる')).to include('着る')
  end

  it 'stem causative verbs in plain form' do
    expect(stem('くわせる')).to include('くう')
    expect(stem('解かす')).to include('解く')
    expect(stem('たたす')).to include('たつ')
    expect(stem('飛ばせる')).to include('飛ぶ')
    expect(stem('とらす')).to include('とる')
    expect(stem('頼ます')).to include('頼む')
    expect(stem('しなせる')).to include('しぬ')
    expect(stem('出させる')).to include('出す')
    expect(stem('ねさせる')).to include('ねる')
    expect(stem('着さす')).to include('着る')
  end

  it 'stem causative verbs in formal form' do
    expect(stem('洗わせます')).to include('洗う')
    expect(stem('かかします')).to include('かく')
    expect(stem('立たします')).to include('立つ')
    expect(stem('よばせます')).to include('よぶ')
    expect(stem('のらせます')).to include('のる')
    expect(stem('飲まします')).to include('飲む')
    expect(stem('しなします')).to include('しぬ')
    expect(stem('汚させます')).to include('汚す')
    expect(stem('たべさせます')).to include('たべる')
    expect(stem('着さします')).to include('着る')
  end

  it 'stem negative causative verbs in plain form' do
    expect(stem('洗わせない')).to include('洗う')
    expect(stem('かかさない')).to include('かく')
    expect(stem('立たさない')).to include('立つ')
    expect(stem('よばせない')).to include('よぶ')
    expect(stem('のらせない')).to include('のる')
    expect(stem('飲まさない')).to include('飲む')
    expect(stem('しなさない')).to include('しぬ')
    expect(stem('汚させない')).to include('汚す')
    expect(stem('たべさせない')).to include('たべる')
    expect(stem('出来ささない')).to include('出来る')
  end

  it 'stem alternative provision verbs in plain form' do
    expect(stem('くったり')).to include('くう')
    expect(stem('解いたり')).to include('解く')
    expect(stem('たったり')).to include('たつ')
    expect(stem('飛んだり')).to include('飛ぶ')
    expect(stem('とったり')).to include('とる')
    expect(stem('頼んだり')).to include('頼む')
    expect(stem('しんだり')).to include('しぬ')
    expect(stem('出したり')).to include('出す')
    expect(stem('ねたり')).to include('ねる')
    expect(stem('着たり')).to include('着る')
  end

  it 'stem imperative verbs in plain form' do
    expect(stem('くえ')).to include('くう')
    expect(stem('解け')).to include('解く')
    expect(stem('たて')).to include('たつ')
    expect(stem('飛べ')).to include('飛ぶ')
    expect(stem('とれ')).to include('とる')
    expect(stem('頼め')).to include('頼む')
    expect(stem('しね')).to include('しぬ')
    expect(stem('出せ')).to include('出す')
    expect(stem('ねろ')).to include('ねる')
    expect(stem('着よ')).to include('着る')
  end

  it 'stem imperative verbs in formal form' do
    expect(stem('洗いなさい')).to include('洗う')
    expect(stem('かきなさい')).to include('かく')
    expect(stem('立ちなさい')).to include('立つ')
    expect(stem('よびなさい')).to include('よぶ')
    expect(stem('のりなさい')).to include('のる')
    expect(stem('飲みなさい')).to include('飲む')
    expect(stem('しになさい')).to include('しぬ')
    expect(stem('汚しなさい')).to include('汚す')
    expect(stem('たべなさい')).to include('たべる')
    expect(stem('着なさい')).to include('着る')
  end

  it 'stem irregular verb する and くる' do
    expect(stem('します')).to include('する')
    expect(stem('しない')).to include('する')
    expect(stem('した')).to include('する')
    expect(stem('して')).to include('する')
    expect(stem('しろ')).to include('する')
    expect(stem('せよ')).to include('する')
    expect(stem('しよう')).to include('する')
    expect(stem('させる')).to include('する')
    expect(stem('さす')).to include('する')
    expect(stem('される')).to include('する')

    expect(stem('きます')).to include('くる')
    expect(stem('こない')).to include('くる')
    expect(stem('きた')).to include('くる')
    expect(stem('きて')).to include('くる')
    expect(stem('こい')).to include('くる')
    expect(stem('こよう')).to include('くる')
    expect(stem('これない')).to include('くる')
    expect(stem('こさせられる')).to include('くる')
  end

  private def stem(token)
    stemmer.stem(token)
  end
end