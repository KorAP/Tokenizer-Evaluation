use std::env;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let splitter =
        nnsplit::NNSplit::load("de", nnsplit::NNSplitOptions::default())?;

    let args: Vec<String> = env::args().collect();
    let filename = &args[1];

     let contents = fs::read_to_string(filename)
         .expect("Something went wrong reading the file");

    let input: Vec<&str> = vec![&contents];
    let splits = &splitter.split(&input)[0];

    for sentence in splits.iter() {
        println!("{}</eos>", sentence.text());
    }

    Ok(())
}